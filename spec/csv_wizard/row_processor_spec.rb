RSpec.describe CsvWizard::RowProcessor do
  let(:mapper) do
    m = CsvWizard::Mapper.new
    m.map("Email", to: :email, required: true)
    m.map("Name", to: :name)
    m.map("Role", to: :role, default: "user")
    m
  end

  it "saves a row with all attributes" do
    row = { "Email" => "test@example.com", "Name" => "John" }
    processor = described_class.new(User, mapper, row, 1)
    expect(processor.save).to be true
  end

  it "returns false for missing required columns" do
    row = { "Name" => "John" }
    processor = described_class.new(User, mapper, row, 2)
    expect(processor.save).to be false
    expect(processor.errors).to include("Email is required")
  end

  it "applies default values for optional columns" do
    row = { "Email" => "test@example.com", "Name" => "John" }
    processor = described_class.new(User, mapper, row, 3)
    processor.save
    user = User.last
    expect(user.role).to eq("user")
  end

  it "runs before_import and after_import callbacks" do
    row = { "Email" => "  test@example.com  ", "Name" => "John" }
    before_cb = ->(attrs) { attrs[:email] = attrs[:email].strip; attrs }
    after_cb  = ->(record) { record.update(role: "admin") }

    processor = described_class.new(User, mapper, row, 4, before_import: before_cb, after_import: after_cb)
    processor.save
    user = User.last
    expect(user.email).to eq("test@example.com")
    expect(user.role).to eq("admin")
  end
end
