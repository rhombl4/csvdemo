require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :routing do
  describe 'routes' do
    it 'products to index' do
      assert_generates '/api/v1/products', { action: 'index', controller: 'api/v1/products' }
    end

    it 'route has format json by default' do
      expect(get '/api/v1/products').to route_to('api/v1/products#index', format: :json)
    end

    it 'constrains only json format' do
      expect(get '/api/v1/products.html').to_not be_routable
    end
  end
end

RSpec.describe Api::V1::ProductsController, type: :controller do
  render_views
  let(:body) { JSON.parse(response.body) }

  describe 'GET #index' do
    before do
      get :index, format: :json
    end

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'has an JSON content-type' do
      expect(response.content_type).to eq('application/json')
    end

    it 'body could be parsed as JSON' do
      expect{body}.not_to raise_error
    end

    context 'response content' do
      it 'contains expected keys' do
        expect(body.keys).to match_array(%w[items total page per_page])
      end

      it 'body has specified type of fields format' do
        expect(body).to match({
          'items'    => instance_of(Array),
          'total'    => instance_of(Integer),
          'page'     => instance_of(Integer),
          'per_page' => instance_of(Integer)
        })
      end
    end
  end

  describe 'pagination' do
    let(:items_count) { body['items'].size }
    let!(:default_per_page) { 6 }
    let!(:pages_count) { 3 }
    let!(:last_page_items_count) { 1 }
    let!(:collection) do
      total = default_per_page * pages_count + last_page_items_count
      create_list :product, total
    end

    def get_index(per_page: nil, page: nil)
      attrs = {}
      attrs.merge!(page: page) if page.present?
      attrs.merge!(per_page: per_page) if per_page.present? 
      get :index, format: :json, params: attrs
    end

    before do
      stub_const('Api::V1::ProductsController::DEFAULT_PER_PAGE', default_per_page)
    end

    it 'enabled by default' do
      get_index
      expect(items_count).to eq default_per_page
    end

    it 'accept param per_page' do
      custom_per_page = 3
      get_index(per_page: custom_per_page)
      expect(items_count).to eq custom_per_page
    end

    it 'accept param page' do
      page = 2
      get_index(page: page)
      expect(body['page']).to eq page
    end

    it 'last page contains correct number of items' do
      get_index page: pages_count + 1
      expect(items_count).to eq last_page_items_count
    end
  end

  describe 'search' do
    context 'by producer' do
      let!(:producer) { 'abc123' }
      let!(:products) { create_list :product, 5 }
      let!(:producers_products) { create_list :product, 3, producer: producer }

      it 'filters result to specified producer' do
        get :index, format: :json, params: { q: { producer_eq: producer } }
        expect(body['total']).to eq producers_products.count
      end
    end
  end
end
