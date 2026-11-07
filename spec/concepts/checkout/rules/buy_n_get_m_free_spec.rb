# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Checkout::Rules::BuyNGetMFree do
  subject(:rule) { described_class.new(code: 'FR', buy: 1, free: 1) }

  def fruit_tea(quantity)
    [Checkout::Item.new(code: 'FR', price: BigDecimal('3.11'), quantity:)]
  end

  it 'gives nothing for a single item' do
    expect(rule.apply(fruit_tea(1))).to eq([])
  end

  { 2 => '3.11', 3 => '3.11', 4 => '6.22' }.each do |quantity, amount|
    it "takes #{amount} off #{quantity} items" do
      discounts = rule.apply(fruit_tea(quantity))

      expect(discounts.map(&:amount)).to eq([BigDecimal(amount)])
      expect(discounts.first.rule).to be(rule)
    end
  end

  it 'leaves other products alone' do
    items = [Checkout::Item.new(code: 'SR', price: BigDecimal('5.00'), quantity: 2)]

    expect(rule.apply(items)).to eq([])
  end

  context 'with buy 2 get 1 free' do
    subject(:rule) { described_class.new(code: 'FR', buy: 2, free: 1) }

    { 3 => '3.11', 5 => '3.11', 6 => '6.22' }.each do |quantity, amount|
      it "takes #{amount} off #{quantity} items" do
        expect(rule.apply(fruit_tea(quantity)).map(&:amount)).to eq([BigDecimal(amount)])
      end
    end
  end
end
