# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "validates_some"
require "minitest/autorun"
require "active_record"
require "sqlite3"
require "active_support/testing/assertions"

# This connects to a SQLite database in RAM, or creates it if it doesn't exist
ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: ":memory:"
)

ActiveRecord::Schema.define do
  # force: true will drop the table if it already exists
  create_table :users, force: true do |t|
    t.string :name
    t.string :nickname
    t.string :surname
    t.string :phone_number
    t.string :email
    t.string :home_address
    t.string :work_address
    t.timestamps
  end
end

module MiniFaker

  @email_counter = 0

  # Generates unique mock email addresses
  def self.email
    "hello_#{@email_counter += 1}@org"
  end

end
