module CsvWizard
  class ImportJob < ActiveJob::Base
    queue_as :default

    def perform(model_name, mappings, file_path, logger: nil)
      model = model_name.constantize
      mapper = Mapper.new
      mappings.each { |csv, attr| mapper.map(csv, to: attr) }

      importer = Object.new.extend(Importer)
      importer.instance_variable_set(:@mapper, mapper)
      importer.instance_variable_set(:@model_class, model)

      failed_rows = importer.import(file_path)

      # Conditional logger
      log =
        if logger
          logger
        elsif defined?(Rails) && Rails.respond_to?(:logger)
          Rails.logger
        else
          require "logging"
          Logging.logger['CsvWizard'].tap { |l| l.level = :info }
        end

      if failed_rows.any?
        log.error("[CSV Import] Errors: #{failed_rows.inspect}")
      else
        log.info("[CSV Import] Completed successfully.")
      end
    end
  end
end
