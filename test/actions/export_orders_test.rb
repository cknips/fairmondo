#   Copyright (c) 2012-2015, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

describe ExportOrders do
  let(:user) { FactoryGirl.create(:private_user, :paypal_data) }
  let(:time_range) { 10.days.ago..Time.now }

  describe 'initialisation' do
    it 'should initialize' do
      ExportOrders.new(user, time_range)
    end
  end

  describe 'CSV export' do
    it 'should export empty CSV data if no orders were placed' do
      export_orders = ExportOrders.new(user, time_range)
      assert(export_orders.csv_data.empty?)
    end

    it 'should export order data for business transaction' do
      lig = FactoryGirl.create(:line_item_group, :sold, message: 'Please handle with extra care!',
                               purchase_id: 'F00000012')


      article = FactoryGirl.create(:article, title: 'Great Expectations', price_cents: 2000)


      business_transaction = FactoryGirl.create(:business_transaction, seller: user)

      export_orders = ExportOrders.new(user, time_range)

      'Purchase ID; Article Title; Quantity; Sold at; Message;
      Payment Address Title; Payment Address Name; Payment Address Company Name; Payment Address Line 1; Payment Address Line 2; Payment Address Zip; Payment Address City;
      Shipping Address Title; Shipping Address Name; Shipping Address Company Name; Shipping Address Line 1; Shipping Address Line 2; Shipping Address Zip; Shipping Address City;'

      assert_equal("Transaction ID;Article ID;Title;Quantity\n#{business_transaction.id};#{business_transaction.article_id};#{business_transaction.article.title};#{business_transaction.quantity_bought}\n",
                   export_orders.csv_data)
    end

    # order by line item group

    it 'should generate a filename containing the dates' do
      date_range = Date.parse('2015-01-01')..Date.parse('2015-10-15')
      export_orders = ExportOrders.new(user, date_range)
      assert_equal('fairmondo_orders_2015-01-01_2015-10-15.csv',
                   export_orders.csv_filename)
    end
  end
end
