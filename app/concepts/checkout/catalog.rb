# frozen_string_literal: true

class Checkout::Catalog
  def self.default
    new([
      Checkout::Product.new(code: 'FR', price: BigDecimal('3.11')),
      Checkout::Product.new(code: 'SR', price: BigDecimal('5.00')),
      Checkout::Product.new(code: 'CF', price: BigDecimal('11.23')),
      Checkout::Product.new(code: 'AJ', price: BigDecimal('7.25'))
    ])
  end

  def initialize(products)
    @products = products.to_h { |product| [product.code, product] }
  end

  def fetch(code)
    @products.fetch(code) { raise Checkout::UnknownProduct, "Unknown product code: #{code}" }
  end

  def products
    @products.values
  end
end
