# frozen_string_literal: true

class CheckoutsController < ApplicationController
  def show
    @result = Checkout::Operation::BuildReceipt.call(codes: params[:items])
    @products = Checkout::Catalog.default.products
    @offers = Checkout::Offers.current
  end
end
