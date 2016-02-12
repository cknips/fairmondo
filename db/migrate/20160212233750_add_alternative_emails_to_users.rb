class AddAlternativeEmailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invoicing_email, :string
    add_column :users, :order_notifications_email, :string
  end
end
