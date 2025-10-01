RSpec.describe CsvWizard::ErrorReporter do
  it "collects and reports errors" do
    reporter = described_class.new
    reporter.add_errors(["Email required"], 2)
    reporter.add_errors(["Name missing"], 3)

    expect(reporter.any?).to be true
    expect(reporter.full_report).to include("Line 2: Email required", "Line 3: Name missing")
  end
end
