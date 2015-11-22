#   Copyright (c) 2012-2015, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

include Warden::Test::Helpers

feature 'Export orders' do
  let(:user) { FactoryGirl.create :private_user }

  scenario 'User visits his profile and sees the export orders form' do
    login_as user
    visit user_path(user)
    within '#seller_line_item_groups' do
      fill_in 'export_orders_from', with: (Date.today << 2).to_s
      fill_in 'export_orders_till', with: Date.today.to_s
      click_button 'export_orders_submit'
    end
    page.status_code.must_equal 200
    page.response_headers['Content-Type'].must_equal 'text/csv'
  end
end