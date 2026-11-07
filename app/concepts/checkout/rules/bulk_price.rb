# frozen_string_literal: true

class Checkout::Rules::BulkPrice
  attr_reader :code, :min_quantity, :price

  def initialize(code:, min_quantity:, price:)
    @code = code
    @min_quantity = min_quantity
    @price = BigDecimal(price)
  end

  def name
    :bulk_price
  end

  def params
    { code:, min_quantity:, price: }
  end

  def apply(items)
    item = items.find { |candidate| candidate.code == code }
    return [] unless item && item.quantity >= min_quantity && price < item.price

    [Checkout::Discount.new(rule: self, amount: (item.price - price) * item.quantity)]
  end
end
