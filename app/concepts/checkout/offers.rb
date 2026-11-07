# frozen_string_literal: true

module Checkout::Offers
  def self.current
    [
      Checkout::Rules::BuyNGetMFree.new(code: 'FR', buy: 1, free: 1),
      Checkout::Rules::BulkPrice.new(code: 'SR', min_quantity: 3, price: '4.50')
    ]
  end
end
