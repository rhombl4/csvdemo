FactoryBot.define do
  factory :product do
    name        { FFaker::Product.product_name }
    photo_url   { FFaker::Image.url }
    barcode     { FFaker::Code.ean }
    price       { FFaker::Random.rand(1_000_000) }
    sku         { FFaker::SSN.ssn }
    producer    { FFaker::Company.name }

    trait :invalid_price do
      price { -FFaker::Random.rand(10) }
    end

    trait :invalid_ean do
      barcode { -FFaker::Random.rand(10) }
    end

    trait :invalid_column do
      name { '' }
    end
  end
end
