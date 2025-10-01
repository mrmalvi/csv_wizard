require "tempfile"

RSpec.describe CsvWizard::Importer do
  let(:importer_class) do
    Class.new do
      extend CsvWizard::Importer
      map_csv_to User do
        column "Email", required: true
        column "Name"
        column "Role", default: "user"
      end
    end
  end

  it "imports CSV and collects failed rows" do
    csv = Tempfile.new
    csv.write("Email,Name\n,test\nok@example.com,John\n")
    csv.rewind

    failed = importer_class.import(csv.path)
    expect(failed.size).to eq(1)
    expect(failed.first[:line]).to eq(2)
  ensure
    csv.close
    csv.unlink
  end
end
