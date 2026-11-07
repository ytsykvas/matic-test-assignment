# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Checkout::Operation::BuildReceipt do
  it 'builds a receipt from codes in any case, separated by commas or spaces' do
    result = described_class.call(codes: 'fr, SR,fr')

    expect(result).to be_success
    expect(result.unknown_codes).to eq([])
    expect(result.receipt.items.map(&:code)).to eq(%w[FR SR])
    expect(result.receipt.items.map(&:quantity)).to eq([2, 1])
  end

  it 'fails with the unknown codes, once each, and no receipt' do
    result = described_class.call(codes: 'FR, xx, XX, zz')

    expect(result).not_to be_success
    expect(result.unknown_codes).to eq(%w[XX ZZ])
    expect(result.receipt).to be_nil
  end

  [nil, ''].each do |codes|
    it "builds an empty receipt from #{codes.inspect}" do
      result = described_class.call(codes:)

      expect(result).to be_success
      expect(result.receipt.items).to be_empty
    end
  end
end
