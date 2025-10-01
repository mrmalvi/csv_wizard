# spec/csv_wizard/import_job_spec.rb
require "spec_helper"
require "tempfile"
require "logging"
require_relative "../../lib/csv_wizard/import_job"
require_relative "../../lib/csv_wizard/mapper"
require_relative "../../lib/csv_wizard/importer"
require_relative "../../lib/csv_wizard/row_processor"

RSpec.describe CsvWizard::ImportJob do
  let(:csv_content) { "Email,Name\nuser@example.com,John Doe\n" }
  let(:file) do
    f = Tempfile.new("test.csv")
    f.write(csv_content)
    f.rewind
    f
  end

  before do
    # Dummy ActiveRecord model
    class DummyUser < ActiveRecord::Base
      self.table_name = "dummy_users"
      connection.create_table table_name, force: true do |t|
        t.string :email
        t.string :name
      end
      validates :email, presence: true
      validates :name, presence: true
    end
  end

  after do
    DummyUser.connection.drop_table("dummy_users", if_exists: true)
    Object.send(:remove_const, :DummyUser)
    file.close
    file.unlink
  end

  let(:mappings) { { "Email" => :email, "Name" => :name } }

  context "with a custom logger" do
    it "logs success messages" do
      logger_double = double("logger", info: nil, error: nil)
      expect(logger_double).to receive(:info).with(/Completed successfully/)
      CsvWizard::ImportJob.new.perform("DummyUser", mappings, file.path, logger: logger_double)
    end
  end

  context "with Rails.logger" do
    before do
      stub_const("Rails", Class.new)
      # Use a regular double instead of `double` inside Rails
      logger_double = instance_double("Logger", info: nil, error: nil)
      Rails.singleton_class.define_method(:logger) { logger_double }
      @rails_logger_double = logger_double
    end

    it "logs success messages using Rails.logger" do
      expect(@rails_logger_double).to receive(:info).with(/Completed successfully/)
      CsvWizard::ImportJob.new.perform("DummyUser", mappings, file.path)
    end
  end

  context "without Rails or custom logger" do
    it "logs success messages using Logging gem" do
      # Logger instance double
      logger_instance = double("LoggerInstance")
      allow(logger_instance).to receive(:info)
      allow(logger_instance).to receive(:error)
      allow(logger_instance).to receive(:level=) # stub the setter

      # Root double that responds to []('CsvWizard') and returns logger_instance
      logging_root = double("LoggingRoot")
      allow(logging_root).to receive(:[]).with('CsvWizard').and_return(logger_instance)

      # Stub Logging.logger to return our root double
      allow(Logging).to receive(:logger).and_return(logging_root)

      CsvWizard::ImportJob.new.perform("DummyUser", mappings, file.path)

      expect(logger_instance).to have_received(:info).with(/Completed successfully/)
    end
  end

  context "when row has validation errors" do
    let(:invalid_csv) { "Email,Name\n,John Doe\n" }
    let(:invalid_file) do
      f = Tempfile.new("invalid.csv")
      f.write(invalid_csv)
      f.rewind
      f
    end

    it "logs errors for invalid rows" do
      logger_double = double("logger", info: nil, error: nil)
      expect(logger_double).to receive(:error).with(/Errors/)
      CsvWizard::ImportJob.new.perform("DummyUser", mappings, invalid_file.path, logger: logger_double)
      invalid_file.close
      invalid_file.unlink
    end
  end
end
