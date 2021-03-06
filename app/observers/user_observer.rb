#   Copyright (c) 2012-2016, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class UserObserver < ActiveRecord::Observer
  def before_save user
    case
    when (user.bank_account_number_changed? ||  user.bank_code_changed?)
      check_blz_and_ktn(user.id, user.bank_account_number, user.bank_code)
    when (user.iban_changed? || user.bic_changed?)
      check_bic_and_iban(user.id, user.iban, user.bic)
    end
  end

  def after_update user
    update_fastbill_account_for user
    update_cleverreach_settings_for user
    deactivate_and_close_active_articles_for_banned user
  end

  def after_create user
    CleverreachAPI.add(user) if user.newsletter?
  end

  private

  def update_fastbill_account_for user
    # this should update the users data with fastbill after the user edits his data
    if user.is_a?(LegalEntity) && user.fastbill_profile_update && user.has_fastbill_profile?
      FastbillUpdateUserWorker.perform_async user.id
    end
  end

  def update_cleverreach_settings_for user
    if user.newsletter_changed?
      cr = CleverreachAPI
      user.newsletter? ? cr.add(user) : cr.remove(user)
    end
  end

  def deactivate_and_close_active_articles_for_banned user
    # deactivates and closes all active articles of banned user
    if user.banned && user.articles.active.limit(1).any?
      user.articles.active.find_each do |article|
        article.deactivate
        article.close
      end
    end
  end

  { blz: :ktn, bic: :iban }.each do |bank_ref, account_ref|
    define_method("check_#{bank_ref}_and_#{account_ref}") do |id, account_number, bank_number|
      begin
        user = User.find(id)
        user.update_column(:bankaccount_warning, !KontoAPI.valid?(bank_ref => bank_number, account_ref => account_number))
      rescue
      end
    end
  end
end
