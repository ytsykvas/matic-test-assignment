# frozen_string_literal: true

class Checkout::Operation::BuildReceipt
  Result = Data.define(:receipt, :unknown_codes) do
    def success?
      unknown_codes.empty?
    end
  end

  def self.call(codes:)
    new(codes).call
  end

  def initialize(codes)
    @codes = codes.to_s.upcase.split(/[\s,]+/).reject(&:empty?)
  end

  def call
    checkout = Checkout.new(*Checkout::Offers.current)
    unknown_codes = []

    @codes.each do |code|
      checkout.scan(code)
    rescue Checkout::UnknownProduct
      unknown_codes << code
    end

    Result.new(receipt: unknown_codes.empty? ? checkout.receipt : nil, unknown_codes: unknown_codes.uniq)
  end
end
