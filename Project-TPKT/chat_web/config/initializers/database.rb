require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: File.expand_path("../../../chat.db", __FILE__) # путь к твоей базе
)