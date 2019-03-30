# frozen_string_literal: true

# Helpers for specs
module TestHelpers
  ATTRIBUTES = ImportCSVFile::ROW_MAP.values
  HEADERS = ['product_name', 'photo_url', 'barcode', 'price_cents',
             'sku (unique id)' ,'producer'].freeze

  def csv_row_headers
    HEADERS
  end

  def product_to_row(product)
    ATTRIBUTES.map { |a| product.attributes[a.to_s] }
  end

  def write_csv(file, data)
    CSV.open(file, "w") do |csv|
      data.each do |row|
        csv << row
      end
    end
  end
end
