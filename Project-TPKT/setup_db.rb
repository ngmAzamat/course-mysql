# setup_db.rb
require 'sqlite3' # 🔹 Подключаем библиотеку sqlite3, которая позволяет работать с файлами .db

db = SQLite3::Database.new "chat.db" # 🔹 Создаём или открываем файл chat.db в текущей директории. Если файл не существует — он будет создан

# 🔹 выполнить следующие инструкции в SQL:
db.execute <<-SQL 
  CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nickname TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
SQL

puts "База данных и таблица созданы." # 🔹 Просто сообщение в консоль, что всё прошло хорошо ✅
