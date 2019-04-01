json.items do
  json.array! @products, partial: 'api/v1/products/product', as: 'product'
end
json.total    @total
json.page     @page
json.per_page @per_page
