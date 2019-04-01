# frozen_string_literals: true

class Api::V1::ProductsController < ApplicationController
  DEFAULT_PER_PAGE = 5

  def index
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || DEFAULT_PER_PAGE).to_i

    @products = Product.ransack(params[:q]).result
    @total = @products.count

    @products = @products.paginate(page: @page, per_page: @per_page)
  end
end
