#   Copyright (c) 2012-2015, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

require_relative '../test_helper'

describe LineItemGroupsController do
  let(:lig) { FactoryGirl.create :line_item_group, :sold, :with_business_transactions, traits: [:paypal, :transport_type1] }
  let(:buyer) { lig.buyer }
  let(:seller) { lig.seller }

  describe "GET 'show'" do
    before do
      sign_in buyer
    end

    it 'should show a success flash when redirected after paypal success' do
      get :show, id: lig.id, paid: 'true'
      flash[:notice].must_equal I18n.t('line_item_group.notices.paypal_success')
    end

    it 'should show an error flash when redirected after paypal cancellation' do
      get :show, id: lig.id, paid: 'false'
      flash[:error].must_equal I18n.t('line_item_group.notices.paypal_cancel')
    end
  end

  describe "GET 'download'" do
    it 'should return 200 if user is logged in' do
      sign_in seller
      csv_data = stub(empty?: false)
      export_orders = mock()
      export_orders.expects(:csv_data).once.returns(csv_data)
      export_orders.expects(:csv_filename).once
      ExportOrders.stubs(:new).returns(export_orders)

      get :download, export_orders_from: '2015-09-22', export_orders_till: '2015-11-22'

      assert_response :success
    end

    it 'should return an error if no orders can be found' do
      sign_in seller
      csv_data = stub(empty?: true)
      export_orders = stub(csv_data: csv_data)
      ExportOrders.stubs(:new).returns(export_orders)

      get :download, export_orders_from: '2015-09-22', export_orders_till: '2015-11-22'

      assert_redirected_to user_path(seller)
      flash[:error].must_equal 'Im vom Dir angegebenen Zeitraum liegen keine Bestellungen.'
    end

    it 'should return an error if the start or end date is incorrect' do
      sign_in seller
      get :download, export_orders_from: '2015-09-22', export_orders_till: nil
      assert_redirected_to user_path(seller)
      flash[:error].must_equal 'Date is incorrect'
    end

    it 'should return an error if the start date is bigger than end date' do
      sign_in seller
      get :download, export_orders_from: '2015-11-22', export_orders_till: '2015-09-22'
      assert_redirected_to user_path(seller)
      flash[:error].must_equal 'Date is incorrect'
    end

    it 'should fail if user is not logged in' do
      get :download, export_orders_from: '2015-09-22', export_orders_till: '2015-11-22'
      assert_redirected_to new_user_session_path
    end
  end
end
