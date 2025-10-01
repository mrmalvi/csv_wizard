RSpec.describe CsvWizard::Mapper do
  it "maps CSV columns to attributes with required and default values" do
    mapper = described_class.new
    mapper.map("Email", to: :email, required: true)
    mapper.map("Name", to: :name)
    mapper.map("Role", to: :role, default: "user")

    expect(mapper.mappings).to eq({ "Email" => :email, "Name" => :name, "Role" => :role })
    expect(mapper.required_columns).to eq(["Email"])
    expect(mapper.defaults).to eq({ role: "user" })
  end
end
