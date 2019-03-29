# frozen_string_literals: true

# Service object for CSV-import
class ImportCSVFile
  require 'CSV'
  ROW_MAP = {
    0 => :name,
    1 => :photo_url,
    2 => :barcode,
    3 => :price,
    4 => :sku,
    5 => :producer
  }.freeze

  def self.process(file)
    import_service = new(file)
    import_service.import
    if import_service.success?
      Rails.logger.info 'Processed with success'
      Rails.logger.info "Results"
      true
    else
      Rails.logger.warn 'Failed to import data:'
      Rails.logger.warn import_service.error
      false
    end
  end

  def initialize(file = nil)
    @source_file = file
  end

  def import
    return self if source.blank?
    # raise 'Not implemented yet'
    source.rewind
    data = CSV(source)
    headers = data.readline
    column_count = headers.size
    result = []
    row_errors = []
    # created_rows_count = 0
    # updated_rows_count = 0
    data.each.with_index do |source_row, i|
      row = source_row.dup
      if row.size != column_count
        row_errors << { i: 'Bad row', data: source_row}
        next
      end

      if row.any?(&:blank?)
        row_errors << { i: 'Empty column', data: source_row}
        next
      end

      sku = row[ROW_MAP.key(:sku)]
      row[ROW_MAP.key(:sku)] = (sku.downcase rescue nil)

      barcode = row[ROW_MAP.key(:barcode)]
      row[ROW_MAP.key(:barcode)] = (Integer(barcode) rescue nil)

      price = row[ROW_MAP.key(:price)]
      row[ROW_MAP.key(:price)] = (Integer(price) rescue nil)

      if faulty_column = row.find_index(&:blank?)
        row_errors << { i: "Faulty value on #{ROW_MAP[faulty_column]}", data: source_row }
        next
      end

      result << row.each_with_object({}).with_index do |(c, hsh), j|
        hsh[ROW_MAP[j]] = c
      end
    end
    
    puts 'result and row_errors filled'

    self
  end

  def error
    return nil if success?
    errors.first
  end

  def success?
    errors.blank?
  end

  private

  def errors
    return @errors if defined? @errors
    @errors = [].tap do |array|
      array.define_singleton_method(:add) { |error| self << error }
    end
  end

  def source
    return @source if defined? @source
    @source = CSVSource.open @source_file
    errors.add('Source file not found') if @source.blank?
    @source
  end
end
