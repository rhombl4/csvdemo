require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'attributes' do
    subject { create(:product).attributes.keys }
    it { is_expected.to include(*%w[name photo_url barcode price sku producer]) }
  end
end
