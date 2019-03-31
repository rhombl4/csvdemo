require 'rails_helper'
require 'test_helpers'

RSpec.describe ImportCSVFile do
  include TestHelpers

  TEMPFILE1 = 'tmp/tmp1.csv'
  TEMPFILE2 = 'tmp/tmp2.csv'

  let(:header) { csv_row_headers }
  let(:row0) { product_to_row build(:product) }
  let(:row1) { product_to_row build(:product) }
  let(:row_wrong_count) { product_to_row(build(:product))[0..-2] }
  let(:row_empty_value) { product_to_row(build(:product, :invalid_column)) }
  let(:row_wrong_price) { product_to_row(build(:product, :invalid_price)) }
  let(:row_wrong_ean) { product_to_row(build(:product, :invalid_ean)) }
  let(:good_rows) { [header, row0, row1] }
  let(:fail_rows) { [header, row0, row1, row_wrong_price, row_wrong_ean, row_wrong_count, row_empty_value] }
  let!(:correct_csv) { write_csv(TEMPFILE1, good_rows) }
  let!(:incorrect_csv) { write_csv(TEMPFILE2, fail_rows) }
  after(:all) { File.delete(TEMPFILE1) }
  after(:all) { File.delete(TEMPFILE2) }
  let(:wrong_filename) { SecureRandom.urlsafe_base64(10) }

  # let :correct_csv_file { create(:product) }
  # let :incorrect_csv_file { create(:product) }
  context 'class methods' do
    subject { ImportCSVFile }
    it 'respond to call' do
      expect(subject).to respond_to(:call).with(1).argument
    end

    it 'return object of boolean type' do
      expect(subject.call(TEMPFILE1)).to be_in([true, false])
    end

    it 'return true on successfull parsing but with faulty rows' do
      expect(subject.call(TEMPFILE2)).to be true
    end

    it 'respond with false on wrong filename' do
      expect(subject.call(wrong_filename)).to be false
    end
  end

  context 'instance methods' do
    describe 'respond to public methods' do
      it { is_expected.to respond_to(:import).with(0).arguments }
      it { is_expected.to respond_to(:success?).with(0).arguments }
      it { is_expected.to respond_to(:error).with(0).arguments }
      it { is_expected.to respond_to(:row_errors).with(0).arguments }
    end

    context 'call result' do
      it('import is self') { expect(subject.import).to be_an_instance_of subject.class }
      it('success? is boolean') { expect(subject.success?).to be_in [true, false] }
      it('row_errors is array') { expect(subject.row_errors).to be_an_instance_of Array }
      it('error is a nil when no errors') { expect(subject.error).to be_nil }
      it 'error is a string on errors' do
        allow(subject).to receive(:errors).and_return(['error'])
        expect(subject.error).to be_an_instance_of String
      end
    end
  end

  context 'processing' do
    subject { ImportCSVFile.new TEMPFILE2 }
    it 'processes the file with invalid records' do
      expect{subject.import}.to change{Product.count}.by(2)
      expect(subject.success?).to be_truthy
      expect(subject.error).to be_nil
      expect(subject.row_errors.size).to eq(4)
    end
  end
end
