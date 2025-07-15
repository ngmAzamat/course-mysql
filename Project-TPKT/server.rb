require 'socket' # знаете для работы с TCP надо socket(это труба между клиентом и сервером)
require 'sqlite3' # библиотека для работы с базами данных

DB = SQLite3::Database.new("chat.db")
DB.results_as_hash = true

clients = [] # клиентов много - а много это массив

def read_exact(socket, n)
  buf = +""
  while buf.bytesize < n
    chunk = socket.read(n - buf.bytesize)
    return nil if chunk.nil? # EOF or connection closed
    buf << chunk
  end
  buf
end

def read_tpkt(socket)
  header = read_exact(socket, 4) # что это
  return nil unless header && header.bytesize == 4 # что это

  version, _, hi, lo = header.unpack("C4") # в клиенте мы соединяли а тут мы розойденяем сообщение
  length = (hi << 8) + lo # что это

  payload = read_exact(socket, length - 4)
  return nil unless payload && payload.bytesize == (length - 4)

  payload.force_encoding('UTF-8') # если кракозябра то это UTF-8
  unless payload.valid_encoding? # если код валидный 
    payload = payload.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?') # конвертация в UTF-8 если еще не UTF-8
  end

  payload
rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
  nil
end

def send_tpkt(socket, data)
  data = data.encode('UTF-8') # все в UTF-8
  length = data.bytesize + 4 # длинна = длинна данных + 4(загаловок)
  header = [3, 0, length >> 8, length & 0xFF].pack("C4") # наш header = Версия(3), Запас(0), Длинна(length >> 8, length & 0xFF) и все вместе(.pack("C4"))
  socket.write(header + data) # отправляем данные загаловка с телом
rescue
  # Ошибка при отправке — игнорируем
end

server = TCPServer.new('0.0.0.0', 4000) # мы запускаем трубу и поток с клиентом
puts "Сервер TPKT запущен на порту 4000" # и логируем это

loop do
  client = server.accept # ждем подключение клиента
  clients << client # сохраняем клиента в список клиентов
  puts "Новый клиент подключился (всего: #{clients.size})" # логируем подключение пользователя

  Thread.new(client) do |sock|
    begin
      port = client.peeraddr[1] # порт - это непонятно что
      nickname = "Гость#{port}" # базаво - nickname эт Гость и порт
      send_tpkt(sock, "Привет, ты #{nickname}") # обращяемся к юсеру через функцию sned_tpkt

      loop do # бесконечный основной цикл
        msg = read_tpkt(sock)

        break if msg.nil? || msg.strip.downcase == "exit" # мы закрываем если ошибка, либо если ничего не пришло(наример ошибка чтения) или exit

        msg = msg.force_encoding('UTF-8') if msg # если кракозябра то это UTF-8
        unless msg.valid_encoding? # если код валидный 
          msg = msg.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?') # конвертация в UTF-8 если еще не UTF-8
        end
        # тут понятно что мы выводим сообщения, однако не понятен принцип работы
        if msg.strip == "/history" # 🔹 Если пользователь отправил /history (пробелы по краям удалены strip).
          rows = DB.execute("SELECT nickname, content, created_at FROM messages ORDER BY id DESC LIMIT 10") #🔹 Выполняется SQL-запрос к базе: SELECT nickname, content, created_at — выбрать нужные поля, FROM messages — из таблицы messages, ORDER BY id DESC — отсортировать по убыванию id, т.е. сначала самые свежие, LIMIT 10 — взять только 10 последних
          rows.reverse.each do |row| # 🔹 Мы переворачиваем массив rows.reverse, чтобы сообщения шли сначала старые → потом новые, как в обычном чате. Итерируем по ним.
            send_tpkt(sock, "[#{row['created_at']}] #{row['nickname']}: #{row['content']}") # отправка сообщение в виде [время] Ник: Сообщение
          end
          next
        end

        if msg.strip.start_with?("/nick ") # если сообщение начинается с /nick
          new_nick = msg.strip[6..].strip
          if new_nick.empty? # а если после /nick путо
            send_tpkt(sock, "Имя не может быть пустым.") # то так нельзя!
          else # а если что есть
            old_nick = nickname # ник теперь старый ник
            nickname = new_nick # а новый ник это ник
            send_tpkt(sock, "Ты теперь: #{nickname}") # и говорим новый ник
            clients.each do |cl| # каждому клиенту
              next if cl == sock
              send_tpkt(cl, "#{old_nick} теперь известен как #{nickname}") # отправляем новое имя одного из клиентов
            end
          end
          next
        end

        puts "#{nickname}: #{msg}" # если кто то пишет то мы это пишем в лог сервера
        DB.execute("INSERT INTO messages (nickname, content) VALUES (?, ?)", [nickname, msg])

        clients.each do |cl| # и каждому клиенту
          next if cl == sock
          send_tpkt(cl, "#{nickname}: #{msg}") # рассылаем сообщение
        end
      end
    ensure
      puts "#{nickname} отключился" # логируем отключение
      clients.delete(sock) # удаляем пользователя
      sock.close # закрываем
    end
  end
end
