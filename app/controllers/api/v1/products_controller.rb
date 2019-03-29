class Api::V1::ProductsController < ApplicationController
  def index
    @page = params[:page] || 1
    @per_page = params[:per_page] || 5

    @products = Product.ransack(params[:q]).result
    @total = @products.count

    @products = @products.paginate(page: @page, per_page: @per_page)
  end
end
