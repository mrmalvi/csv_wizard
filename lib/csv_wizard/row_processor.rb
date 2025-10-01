module CsvWizard
  class RowProcessor
    attr_reader :model, :mapper, :row, :line_number, :errors

    def initialize(model, mapper, row, line_number, defaults: {}, before_import: nil, after_import: nil)
      @model = model
      @mapper = mapper
      @row = row
      @line_number = line_number
      @errors = []
      @defaults = defaults
      @before_import = before_import
      @after_import = after_import
    end

    def save
      missing = mapper.required_columns.select { |col| row[col].nil? || row[col].strip.empty? }
      unless missing.empty?
        @errors = missing.map { |col| "#{col} is required" }
        return false
      end

      attrs = mapped_attributes
      attrs = @before_import.call(attrs) if @before_import

      record = model.new(attrs)
      if record.save
        @after_import.call(record) if @after_import
        true
      else
        @errors = record.errors.full_messages
        false
      end
    rescue => e
      @errors = ["Exception: #{e.message}"]
      false
    end

    private

    def mapped_attributes
      mapper.mappings.each_with_object({}) do |(csv_col, attr), hash|
        hash[attr] = row[csv_col] || @defaults[attr] || mapper.defaults[attr]
      end
    end
  end
end
