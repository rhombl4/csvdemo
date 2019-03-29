require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe "GET #index" do
    before do
      get :index, format: :json
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has an JSON content-type' do
      expect(response.header['Content-Type']).to include('application/json')
    end

    it 'contains expected keys' do
      body = JSON.parse(response.body)
      expect(body.keys).to match_array(%i[items total page per_page])
    end
  end
end
