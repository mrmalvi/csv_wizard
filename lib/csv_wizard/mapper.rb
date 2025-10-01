module CsvWizard
  class Mapper
    attr_reader :mappings

    def initialize
      @mappings = {}
      @required_columns = []
      @defaults = {}
    end

    def map(csv_column, to:, required: false, default: nil)
      @mappings[csv_column] = to
      @required_columns << csv_column if required
      @defaults[to] = default if default
    end

    def required_columns
      @required_columns
    end

    def defaults
      @defaults
    end
  end
end
