require 'rails_helper'

RSpec.describe CSVSource do
  context 'class call' do
    it 'use default file without argument' do
      stub_const('CSVSource::DEFAULT_FILENAME', 'spec/fixtures/files/default.csv')
      source = subject.class.call
      expect(source).to be_instance_of(File)
      expect(source.path).to include('default')
    end

    it 'accept parameter as a source file' do
      source = subject.class.call('spec/fixtures/files/sample.csv')
      expect(source).to be_instance_of(File)
      expect(source.path).to include('sample.csv')

    end

    it 'returns nil when wrong filename' do
      source = subject.class.call SecureRandom.urlsafe_base64(10)
      expect(source).to be_nil
    end
  end
end
