#   Copyright (c) 2012-2015, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

describe ExportOrders do
  let(:user) { FactoryGirl.create(:private_user, :paypal_data) }
  let(:time_range) { 10.days.ago..Time.now }

  describe 'initialisation' do
    it 'should initialize' do
      export_orders = ExportOrders.new(user, time_range)
    end
  end

  describe 'CSV export' do
    it 'should export empty CSV data if no orders were placed' do
      export_orders = ExportOrders.new(user, time_range)
      assert(export_orders.csv_data.empty?)
    end

    it 'should export order data for business transaction' do
      business_transaction = FactoryGirl.create(:business_transaction, seller: user)

      export_orders = ExportOrders.new(user, time_range)

      assert_equal("Transaction ID;Article ID;Title;Quantity\n#{business_transaction.id};#{business_transaction.article_id};#{business_transaction.article.title};#{business_transaction.quantity_bought}\n",
                   export_orders.csv_data)
    end
  end
end
