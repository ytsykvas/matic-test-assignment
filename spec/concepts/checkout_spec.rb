# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Checkout do
  subject(:checkout) { described_class.new(*Checkout::Offers.current) }

  def scan(checkout, codes)
    codes.each { |code| checkout.scan(code) }
  end

  describe '#total' do
    [
      [%w[FR SR FR FR CF], '22.45'],
      [%w[FR FR], '3.11'],
      [%w[SR SR FR SR], '16.61']
    ].each do |codes, expected|
      it "charges #{expected} for #{codes.join(', ')}" do
        scan(checkout, codes)

        expect(checkout.total).to eq(BigDecimal(expected))
      end
    end

    it 'takes prices from the given catalog' do
      catalog = Checkout::Catalog.new([Checkout::Product.new(code: 'XX', price: BigDecimal('1.00'))])
      checkout = described_class.new(catalog:)
      checkout.scan('XX')

      expect(checkout.total).to eq(BigDecimal('1.00'))
    end

    it 'does not depend on scan order' do
      totals = [%w[SR SR SR FR FR], %w[FR SR FR SR SR], %w[SR FR SR FR SR]].map do |codes|
        checkout = described_class.new(*Checkout::Offers.current)
        scan(checkout, codes)
        checkout.total
      end

      expect(totals).to all(eq(BigDecimal('16.61')))
    end

    it 'charges full price for a product no rule mentions' do
      scan(checkout, %w[AJ FR FR SR SR SR])

      expect(checkout.total).to eq(BigDecimal('23.86'))
    end

    it 'can be totalled twice and scanned after totalling' do
      checkout.scan('FR')

      expect(checkout.total).to eq(BigDecimal('3.11'))
      expect(checkout.total).to eq(BigDecimal('3.11'))
      expect(checkout.scan('FR').total).to eq(BigDecimal('3.11'))
    end

    it 'adds up discounts from several rules for the same product' do
      checkout = described_class.new(
        Checkout::Rules::BuyNGetMFree.new(code: 'FR', buy: 1, free: 1),
        Checkout::Rules::BulkPrice.new(code: 'FR', min_quantity: 2, price: '3.00')
      )
      scan(checkout, %w[FR FR])

      expect(checkout.total).to eq(BigDecimal('2.89'))
    end

    it 'accepts a new rule without changes' do
      ten_percent_off = Class.new do
        def name
          :ten_percent_off
        end

        def params
          {}
        end

        def apply(items)
          [Checkout::Discount.new(rule: self, amount: (items.sum(BigDecimal('0'), &:subtotal) * BigDecimal('0.1')).round(2))]
        end
      end.new
      checkout = described_class.new(ten_percent_off)
      scan(checkout, %w[FR SR])

      expect(checkout.total).to eq(BigDecimal('7.30'))
    end
  end

  describe '#scan' do
    it 'raises on an unknown product code' do
      expect { checkout.scan('XX') }.to raise_error(Checkout::UnknownProduct)
    end
  end

  describe '#receipt' do
    it 'lists items in scan order with quantities' do
      scan(checkout, %w[FR SR FR FR CF])
      receipt = checkout.receipt

      expect(receipt.items.map(&:code)).to eq(%w[FR SR CF])
      expect(receipt.items.map(&:quantity)).to eq([3, 1, 1])
    end

    it 'names the rules that gave discounts and adds up' do
      scan(checkout, %w[FR SR FR FR CF])
      receipt = checkout.receipt

      expect(receipt.discounts.map { |discount| discount.rule.name }).to eq([:buy_n_get_m_free])
      expect(receipt.subtotal).to eq(BigDecimal('25.56'))
      expect(receipt.total).to eq(BigDecimal('22.45'))
    end

    it 'is empty for an empty basket' do
      receipt = checkout.receipt

      expect(receipt.items).to be_empty
      expect(receipt.discounts).to be_empty
      expect(receipt.total).to eq(BigDecimal('0'))
    end
  end
end
