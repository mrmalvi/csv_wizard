module CsvWizard
  class ErrorReporter
    attr_reader :row_errors

    def initialize
      @row_errors = {}
    end

    def add_errors(errors, line_number)
      @row_errors[line_number] = errors
    end

    def any?
      row_errors.any?
    end

    def full_report
      row_errors.map { |line, errors| "Line #{line}: #{errors.join(", ")}" }.join("\n")
    end
  end
end
