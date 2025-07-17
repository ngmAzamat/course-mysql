require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.expand_path("db/development.sqlite3", __dir__)
)