# frozen_string_literal: true

class Checkout::Rules::BuyNGetMFree
  attr_reader :code, :buy, :free

  def initialize(code:, buy:, free:)
    @code = code
    @buy = buy
    @free = free
  end

  def name
    :buy_n_get_m_free
  end

  def params
    { code:, buy:, free: }
  end

  def apply(items)
    item = items.find { |candidate| candidate.code == code }
    return [] unless item

    free_quantity = item.quantity / (buy + free) * free
    return [] if free_quantity.zero?

    [Checkout::Discount.new(rule: self, amount: item.price * free_quantity)]
  end
end
