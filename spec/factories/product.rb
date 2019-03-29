FactoryBot.define do
  factory :product do
    name        { FFaker::Product.product_name }
    photo_url   { FFaker::Image.url }
    barcode     { FFaker::Code.ean }
    price       { FFaker::Random.rand(1_000_000) }
    sku         { FFaker::SSN.ssn }
    producer    { FFaker::Company.name }
  end
end
