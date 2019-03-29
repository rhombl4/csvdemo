namespace :fetch_data do
  desc "Import data from csv-file"
  task csv_file: :environment do
    ImportCSVFile.process(ENV['file'])
  end
end
