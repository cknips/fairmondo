class BusinessTransactionRefinery < ApplicationRefinery

  def default
    [
      :selected_transport, :selected_payment, :tos_accepted, :message,
      :quantity_bought, :refund_reason, :refund_explanation,
      :billed_for_fair, :billed_for_fee, :billed_for_discount,
      :shipping_address_id, :billing_address_id
      # billed_for are booleans for checking if this transaction is already billed
    ]
  end

  def edit
    default
  end
end
