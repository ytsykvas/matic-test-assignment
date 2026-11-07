# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Checkout::Rules::BulkPrice do
  subject(:rule) { described_class.new(code: 'SR', min_quantity: 3, price: '4.50') }

  def strawberries(quantity)
    [Checkout::Item.new(code: 'SR', price: BigDecimal('5.00'), quantity:)]
  end

  it 'gives nothing below the minimum quantity' do
    expect(rule.apply(strawberries(2))).to eq([])
  end

  { 3 => '1.50', 10 => '5.00' }.each do |quantity, amount|
    it "takes #{amount} off #{quantity} items" do
      discounts = rule.apply(strawberries(quantity))

      expect(discounts.map(&:amount)).to eq([BigDecimal(amount)])
      expect(discounts.first.rule).to be(rule)
    end
  end

  it 'leaves other products alone' do
    items = [Checkout::Item.new(code: 'FR', price: BigDecimal('3.11'), quantity: 5)]

    expect(rule.apply(items)).to eq([])
  end

  it 'gives nothing when the bulk price is not lower' do
    rule = described_class.new(code: 'SR', min_quantity: 3, price: '5.00')

    expect(rule.apply(strawberries(3))).to eq([])
  end

  it 'keeps the bulk price as BigDecimal in its params' do
    expect(rule.params).to eq({ code: 'SR', min_quantity: 3, price: BigDecimal('4.50') })
  end
end
