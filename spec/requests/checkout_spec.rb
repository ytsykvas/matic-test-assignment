# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GET /checkout', type: :request do
  it 'starts empty at the root' do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('No products scanned yet.')
  end

  it 'shows the receipt with current offers applied' do
    get checkout_path(items: 'FR,SR,FR,FR,CF')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('$22.45', 'FR: buy 1, get 1 free', 'SR: 3+ for $4.50 each', 'Fruit Tea')
  end

  it 'reports unknown codes instead of a receipt' do
    get checkout_path(items: 'FR,XX')

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Unknown product codes: XX')
    expect(response.body).not_to include('Subtotal')
  end
end
