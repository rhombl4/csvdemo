# frozen_string_literals: true

# Service object for CSV-import
class ImportCSVFile
  ROW_MAP = {
    0 => :name,
    1 => :photo_url,
    2 => :barcode,
    3 => :price,
    4 => :sku,
    5 => :producer
  }.freeze

  def self.call(file)
    import_service = new(file)
    import_service.import
    if import_service.success?
      Rails.logger.info 'Processed with success'
      if import_service.row_errors.present?
        Rails.logger.info 'Entries with errors:'
        import_service.row_errors.each { |e| Rails.logger.info "Failed entry: #{e.to_s}"}
      end
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

    source.rewind
    data = CSV(source)

    headers = data.readline
    if headers.blank?
      errors.add 'No data'
      return self
    end

    result = process_data(data, rows_count: headers.size)
    # TODO: add counter for created/updated records

    return self if result.empty?

    import = Product.import result, batch_size: 1000, on_duplicate_key_update: {
      conflict_target: %i[sku], columns: %i[name photo_url barcode price producer]
    }
    errors.add 'Error during store to database' if import.blank?

    self
  end

  def error
    return nil if success?
    errors.first
  end

  def success?
    errors.blank?
  end

  def row_errors
    @row_errors ||= []
  end

  private

  def process_data(data, rows_count:)
    # TODO: refactor this int oa separate service
    data.each_with_object([]).with_index do |(source_row, arry), i|
      row = source_row.dup

      next if detect_wrong_column_count(row, rows_count, i)
      next if detect_empty_column(row, i)
      coerse_row_values(row)
      next if detect_falsy_coersed_values(row, source_row, i)

      product_hash = row.each_with_object({}).with_index do |(c, hsh), j|
        hsh[ROW_MAP[j]] = c
      end

      arry << product_hash
      # TODO: change the flow to saving by batches. this will reduce
      # memory usage for large CSVs
      # save_batch if arry.size > N
      # clean_arry
    end
  end

  def detect_wrong_column_count(row, rows_count, number)
    return false if row.size == rows_count
    add_error(row: number, error: 'Bad row', data: row)
    true
  end

  def detect_empty_column(row, number)
    return false if row.none?(&:blank?)
    add_error(row: number, error: 'Empty column', data: row)
    true
  end

  def coerse_row_values(row)
    row[ROW_MAP.key(:sku)]     = downcased_string(row[ROW_MAP.key(:sku)])
    row[ROW_MAP.key(:barcode)] = positive_integer(row[ROW_MAP.key(:barcode)])
    row[ROW_MAP.key(:price)]   = positive_integer(row[ROW_MAP.key(:price)])
  end

  def detect_falsy_coersed_values(row, source_row, number)
    faulty_column = row.find_index(&:blank?)
    return false if faulty_column.blank?
    col = ROW_MAP[faulty_column]
    add_error(row: number, data: source_row, error: "Faulty value at #{col}")
    true
  end

  def positive_integer(val)
    integer = Integer(val)
    integer.positive? ? integer : nil
  rescue StandardError
    nil
  end

  def downcased_string(val)
    val.downcase
  rescue StandardError
    nil
  end

  def add_error(row:, error:, data:)
    error_hash = { row: row, error: error, data: data }
    row_errors << error_hash
  end

  def errors
    return @errors if defined? @errors
    @errors = [].tap do |array|
      array.define_singleton_method(:add) { |error| self << error }
    end
  end

  def source
    return @source if defined? @source
    @source = CSVSource.call(@source_file)
    errors.add('Source file not found') if @source.blank?
    @source
  end
end
