# CsvWizard

CsvWizard is a Ruby gem for **importing CSV files into Rails models** with support for:

- Required fields
- Default values
- Row-level validation
- Pre- and post-import hooks
- Logging with Rails.logger or the Logging gem

It is designed to simplify CSV imports in Rails applications.

---

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem "csv_wizard", "~> 0.1.0", git: "https://github.com/username/csv_wizard.git"
```

Then run:

```bash
bundle install
```

---

## Requirements

- Ruby >= 2.6
- Rails >= 6.0

Optional dependency for logging:

```ruby
gem "logging", ">= 2.3"
```

---

## Usage

### 1. Basic Import

```ruby
mappings = {
  "Name" => :name,
  "Email" => :email,
  "Age" => :age
}

file_path = "path/to/users.csv"

CsvWizard::ImportJob.new.perform("User", mappings, file_path)
```

- `model_name`: The name of the Rails model to import to.
- `mappings`: A hash mapping CSV column headers to model attributes.
- `file_path`: Path to the CSV file.

---

### 2. Using Pre- and Post-Processing Hooks

```ruby
importer = Object.new.extend(CsvWizard::Importer)
importer.map_csv_to(User) do
  column "Name", required: true
  column "Email", required: true
  column "Age", default: 18
end

failed_rows = importer.import(
  "path/to/users.csv",
  before_import: ->(attrs) { attrs[:name] = attrs[:name].strip },
  after_import: ->(record) { puts "Imported #{record.id}" }
)

puts failed_rows.inspect
```

---

### 3. Handling Logging

- By default, `CsvWizard::ImportJob` logs via **Rails.logger** if Rails is defined.
- Otherwise, it uses the **Logging gem**.

```ruby
require "logging"
logger = Logging.logger["CsvWizard"]
logger.level = :info

CsvWizard::ImportJob.new.perform("User", mappings, file_path, logger: logger)
```

---

### 4. Error Reporting

You can use `CsvWizard::ErrorReporter` to generate a full report of errors:

```ruby
reporter = CsvWizard::ErrorReporter.new
reporter.add_errors(["Name is required", "Email is invalid"], 2)
reporter.add_errors(["Age must be numeric"], 5)

puts reporter.full_report
# Output:
# Line 2: Name is required, Email is invalid
# Line 5: Age must be numeric
```

---

### 5. Example CSV

```csv
Name,Email,Age
John Doe,john@example.com,30
Jane Smith,,25
Bob, bob@example.com,
```

- Missing values trigger **validation errors**.
- Default values are applied if configured.

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my_feature`)
3. Commit your changes (`git commit -am 'Add feature'`)
4. Push to the branch (`git push origin feature/my_feature`)
5. Open a Pull Request

---

## License

MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

---

## Metadata for RubyGems

- Homepage: [https://github.com/username/csv_wizard](https://github.com/username/csv_wizard)
- Source code: [https://github.com/username/csv_wizard](https://github.com/username/csv_wizard)
- Required Ruby version: >= 2.6
- Required Rails version: >= 6.0

---

## Summary

CsvWizard makes CSV imports **easy, reliable, and Rails-friendly**.
It supports validations, defaults, hooks, and error reporting to make importing data **safe and efficient**.
