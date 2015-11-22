require 'csv'

class ExportOrders
  CSV_HEADERS = ['Transaction ID', 'Article ID', 'Title', 'Quantity']

  def initialize(user, time_range)
    @user = user
    @time_range = time_range
    set_business_transactions
  end

  def csv_data
    csv_data = CSV.generate(col_sep: ';', write_headers: true, headers: CSV_HEADERS) do |data|
      @business_transactions.each do |bt|
        data << [bt.id, bt.article_id, bt.article.title, bt.quantity_bought]
      end
    end
    csv_data
  end

  private

  def set_business_transactions
    @business_transactions = BusinessTransaction
      .joins(:line_item_group, :article)
      .where(line_item_groups: { seller_id: @user.id })
  end
end
