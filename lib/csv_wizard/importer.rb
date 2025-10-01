module CsvWizard
  module Importer
    def map_csv_to(model_class, &block)
      @mapper = Mapper.new
      instance_eval(&block)
      @model_class = model_class
    end

    def column(name, required: false, default: nil)
      @mapper.map(name, to: name.downcase.to_sym, required: required, default: default)
    end

    def import(file_path, before_import: nil, after_import: nil)
      failed_rows = []

      CSV.foreach(file_path, headers: true).with_index(2) do |row, idx|
        processor = RowProcessor.new(@model_class, @mapper, row.to_h, idx, before_import: before_import, after_import: after_import)
        success = processor.save
        failed_rows << { line: idx, row: row.to_h, errors: processor.errors } unless success
      end

      failed_rows
    end
  end
end
