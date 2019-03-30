namespace :fetch_data do
  desc 'Import data from csv-file'
  task csv_file: :environment do
    ImportCSVFile.call(ENV['file'])
  end

  desc 'Clean DB'
  task clean_db: :environment do
    Product.delete_all
  end
end
