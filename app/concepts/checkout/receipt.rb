# frozen_string_literal: true

Checkout::Receipt = Data.define(:items, :discounts) do
  def subtotal
    items.sum(BigDecimal('0'), &:subtotal)
  end

  def total
    subtotal - discounts.sum(BigDecimal('0'), &:amount)
  end
end
