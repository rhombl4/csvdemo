# frozen_string_literal: true

# Help-class for CSV-import
class CSVSource
  DEFAULT_FILENAME = Rails.root.join('public', 'sources', 'data.csv').freeze

  class << self
    def open(source_file = nil)
      File.open filename(source_file)
    rescue
      Rails.logger.error 'Unable to open such file...'
      nil
    end

    private

    def filename(source_file)
      if source_file.present?
        Rails.logger.info "Using file for data-source: #{source_file}"
        source_file
      else
        Rails.logger.info "Using Default file for data-source: #{DEFAULT_FILENAME}"
        DEFAULT_FILENAME
      end
    end
  end
end
