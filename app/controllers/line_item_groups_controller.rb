#   Copyright (c) 2012-2015, Fairmondo eG.  This file is
#   licensed under the GNU Affero General Public License version 3 or later.
#   See the COPYRIGHT file for details.

class LineItemGroupsController < ApplicationController
  respond_to :html

  before_action :set_line_item_group, only: :show
  before_action :set_tab, only: :show

  def show
    authorize @line_item_group
    @abacus = Abacus.new(@line_item_group)
    if params[:paid] == 'true'
      flash[:notice] = I18n.t 'line_item_group.notices.paypal_success'
    elsif params[:paid] == 'false'
      flash[:error] = I18n.t 'line_item_group.notices.paypal_cancel'
    end
    respond_with @line_item_group do |format|
      format.html
    end
    clear_belboon_tracking_token_from_user if line_item_group_sold?
  end

  def download
    begin
      authorize LineItemGroup
      set_time_range
      export_orders = ExportOrders.new(current_user, @time_range)
      send_data(export_orders.csv_data, filename: 'export_orders.csv', type: 'text/csv')
    rescue ArgumentError
      flash[:error] = 'Date is incorrect'
      redirect_to user_path(current_user)
    end
  end

  private

  def set_line_item_group
    @line_item_group = LineItemGroup.find(params[:id])
  end

  def set_tab
    if params[:tab] == 'payments' || (current_user == @line_item_group.buyer && !params[:tab])
      @tab = :payments
    elsif params[:tab] == 'transports' || (current_user == @line_item_group.seller && !params[:tab])
      @tab = :transports
    else
      @tab = :rating
    end
  end

  def line_item_group_sold?
    @line_item_group && @line_item_group.sold_at?
  end

  def set_time_range
    begin
      start_date = Date.parse(params[:export_orders_from])
      end_date = Date.parse(params[:export_orders_till])
      @time_range = start_date..end_date
    rescue TypeError, ArgumentError
      raise ArgumentError.new
    end
  end
end
