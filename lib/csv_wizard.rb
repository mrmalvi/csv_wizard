# frozen_string_literal: true
require "csv"
require "active_support"
require "active_record"
require "active_job"

require "csv_wizard/importer"
require "csv_wizard/mapper"
require "csv_wizard/row_processor"
require "csv_wizard/error_reporter"
require "csv_wizard/import_job"

module CsvWizard
  class Error < StandardError; end
  # Fucked up
end
