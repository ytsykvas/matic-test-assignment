# frozen_string_literal: true

Checkout::Item = Data.define(:code, :price, :quantity) do
  def subtotal
    price * quantity
  end
end
