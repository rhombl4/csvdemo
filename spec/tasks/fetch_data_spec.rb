require 'rails_helper'
require 'rake'

describe 'fetch_data rake tasks' do
  before :all do
    Rake.application.rake_require 'tasks/fetch_data'
    Rake::Task.define_task(:environment)
  end

  let(:run_csv_file) do
    Rake::Task['fetch_data:csv_file'].reenable
    Rake.application.invoke_task 'fetch_data:csv_file'
  end

  let('run_clean_db') do
    Rake::Task['fetch_data:clean_db'].reenable
    Rake.application.invoke_task 'fetch_data:clean_db'
  end

  context 'cleanup database' do
    let(:create_records) { create_list :product, 5 }

    it 'clean database' do
      expect { create_records }.to change(Product, :count).by(5)
      expect { run_clean_db }.to change(Product, :count).to(0)
    end
  end

  context 'run service for processing' do
    before(:each) { allow(ImportCSVFile).to receive(:call) }
    after(:each) { run_csv_file }

    it 'run processing service' do
      expect(ImportCSVFile).to receive(:call).with(nil).once
    end

    it 'accept filename thru env' do
      ENV['file'] = 'some.csv'
      expect(ImportCSVFile).not_to receive(:call).with(nil)
      expect(ImportCSVFile).to receive(:call).with(/^some\.csv$/).once
    end
  end
end
