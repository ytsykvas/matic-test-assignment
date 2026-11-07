# frozen_string_literal: true

class Checkout
  UnknownProduct = Class.new(StandardError)

  def initialize(*rules, catalog: Catalog.default)
    @rules = rules
    @catalog = catalog
    @quantities = Hash.new(0)
  end

  def scan(code)
    @quantities[@catalog.fetch(code)] += 1
    self
  end

  def receipt
    items = @quantities.map { |product, quantity| Item.new(code: product.code, price: product.price, quantity:) }
    Receipt.new(items:, discounts: @rules.flat_map { |rule| rule.apply(items) })
  end

  def total
    receipt.total
  end
end
