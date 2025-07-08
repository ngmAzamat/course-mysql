### Что такое TPKT

TPKT: это такая надстройка над TCP, она нужна что бы неконторые приемусчества UDP появились и в TCP.

1. UDP: это сообщения, булытки с водой
2. TCP: это поток, труба в которой нету разделения на бутылки
3. TCP с TPKT: это сообщения, бутылки с водой

### Почему не UDP

UDP: менее надежен, подходит максимум для youtube где не настолько важен каждый кадо
TCP: более надежен, подходит для чата где каждая буква или слово важно что бы не поняли так как не надо

### TPKT

тут мы делаем 4 байтовый заголовок:

- 1 байт - version
- 1 байт - reserver
- 2 байта - длинна пакета

и ключ к успеху в длинне пакета мы по сути решаем сколько символов продлится сообщение и потом оно заершится и другое идет.



### Проэкт TPKT

- надо сделать консольный чат, однопоточной для одного клиента, нужен сервер и клиент, и разделяя сообщения новый сторой, на ruby
- потом обновить до чат многопоточный для многих пользователей, добавить TPKT, слелать многосторчные сообщения

### Реализация

#### Этап I: Однопользовательский TPKT-чат

##### Что делаем

- Клиент пишет в консоли → сообщение отправляется
- Сервер получает и выводит → отвечает, например, Ок: <сообщение>
- Используется TPKT для чёткого разделения сообщений


##### server.rb

```ruby
require 'socket' # Подключаем стандартную библиотеку Ruby для работы с TCP-сокетами

def read_tpkt(socket) # Функция для чтения одного TPKT-пакета из TCP-потока
  header = socket.read(4) # Читаем первые 4 байта — это TPKT-заголовок (version, reserved, length)
  return nil unless header && header.bytesize == 4 # Если меньше 4 байт — значит, соединение разорвано
  version, _, hi, lo = header.bytes.unpack("C4") # Распаковываем байты: version=1, reserved=2, hi=3, lo=4
  raise "Неверная версия TPKT" unless version == 3 # Проверка: версия должна быть 3
  length = (hi << 8) + lo # Склеиваем hi и lo в 16-битную длину: длина = (hi * 256) + lo
  socket.read(length - 4) # Читаем оставшиеся байты полезной нагрузки (длина - 4 заголовочных байта)
end

def send_tpkt(socket, data) # Функция для отправки данных с обёрткой в TPKT-заголовок
  length = data.bytesize + 4 # Общая длина пакета = размер данных + 4 байта заголовка
  header = [3, 0, length >> 8, length & 0xFF].pack("C4") 
  # Формируем заголовок:
  # version = 3, reserved = 0
  # затем длина в двух байтах: сначала старший байт (>> 8), потом младший (& 0xFF)
  socket.write(header + data) # Отправляем заголовок и данные в TCP-сокет
end

server = TCPServer.new('localhost', 4000) # созданием TCP на localhost:4000 - мы создаем канал(трубу) со стороны сервера
puts "Сервер запущен на порту 4000" # логируем создание TCP на localhost:4000

client = server.accept 
# Сервер "висит", пока кто-то не подключится
# После подключения мы получаем объект `client` для общения с клиентом
puts "Клиент подключился!" # когда кто то подключился логируем подключение


loop do # Бесконечный цикл для приёма сообщений
  msg = read_tpkt(client) # Читаем одно сообщение от клиента
  break if msg.nil? || msg.strip.downcase == "exit" 
  # Если клиент ничего не отправил или написал "exit" — выходим из цикла
  puts "Клиент: #{msg}" # Печатаем сообщение клиента
  send_tpkt(client, "Ок: #{msg}") # Отправляем ответ обратно через TPKT
end

puts "Клиент отключился." # логируем отключение
client.close # отключаемся
```

##### client.rb

```ruby
require 'socket' # Подключаем стандартную библиотеку Ruby для работы с TCP-сокетами

def read_tpkt(socket)
  header = socket.read(4) # Читаем заголовок
  version, _, hi, lo = header.bytes.unpack("C4") # Распаковываем байты
  length = (hi << 8) + lo # Считаем длину
  socket.read(length - 4) # Читаем данные
end

def send_tpkt(socket, data) # не знаю
  length = data.bytesize + 4 # не знаю
  header = [3, 0, length >> 8, length & 0xFF].pack("C4") # не знаю
  socket.write(header + data) # не знаю
end

socket = TCPSocket.new('localhost', 4000)  # подключение к TCP localhost:4000 - мы создаем канал(трубу) со стороны клиента
puts "Подключено к серверу. Пиши сообщения (или 'exit'):" # логируем поключение к TCP localhost:4000, делаем поле ввода

loop do # Это просто бесконечный цикл, пока пользователь не напишет 'exit'
  print "> " # Печать приглашения
  input = gets # Получение строки с клавиатуры
  break if input.nil? # Если ввода нет (Ctrl+D или закрыли stdin)
  send_tpkt(socket, input.chomp) # Отправляем строку без \n
  response = read_tpkt(socket) # Читаем ответ от сервера
  puts "Сервер: #{response}"
end

socket.close # логируем отключение
puts "Отключено от сервера" # отключаемся
```

##### Терминал

Открой два терминала:
В первом: `ruby server.rb`
Во втором: `ruby client.rb`
Пиши сообщения в клиенте → они отправятся по TPKT → сервер ответит.

#### Этап II: Многопоточность

##### 🧠 Цель

Сделать консольный чат-сервер, который:

- принимает много клиентов одновременно;
- читаем и пишем сообщения через TPKT;
- пересылает сообщение от клиента всем остальным клиентам (как в общем чате).

##### 🧩 Что меняется

Сервер:

- добавляем Thread.new для каждого клиента;
- храним список всех клиентов;
- когда один клиент что-то пишет → пересылаем другим.

Клиент:

- запускаем один поток для отправки, другой для чтения;
- читаем/пишем через TPKT, как раньше.

##### server.rb

```ruby
require 'socket'
clients = []

def read_tpkt(socket)
  header = socket.read(4)
  return nil unless header && header.bytesize == 4
  version, _, hi, lo = header.unpack("C4")
  length = (hi << 8) + lo
  socket.read(length - 4)
rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
  nil
end
  

def send_tpkt(socket, data)
  length = data.bytesize + 4
  header = [3, 0, length >> 8, length & 0xFF].pack("C4")
  socket.write(header + data)
rescue
  # Ошибка при отправке — игнорируем (например, клиент вышел)
end

server = TCPServer.new('192.168.100.90', 4000)
puts "Сервер TPKT запущен на порту 4000"

loop do
  client = server.accept
  clients << client
  puts "Новый клиент подключился (всего: #{clients.size})"

  Thread.new(client) do |sock|
    begin
      nickname = "Гость#{sock.object_id.to_s[-3..]}"
      send_tpkt(sock, "Привет, ты #{nickname}")
  
      loop do
        msg = read_tpkt(sock)
        break if msg.nil? || msg.strip.downcase == "exit"
  
        msg = msg.force_encoding("UTF-8") if msg
  
        if msg.strip.start_with?("/nick ")
          new_nick = msg.strip[6..].strip
          if new_nick.empty?
            send_tpkt(sock, "Имя не может быть пустым.")
          else
            old_nick = nickname
            nickname = new_nick
            send_tpkt(sock, "Ты теперь: #{nickname}")
            clients.each do |cl|
              next if cl == sock
              send_tpkt(cl, "#{old_nick} теперь известен как #{nickname}")
            end
          end
          next
        end
  
        puts "#{nickname}: #{msg}"
        clients.each do |cl|
          next if cl == sock
          send_tpkt(cl, "#{nickname}: #{msg}")
        end
      end
    rescue => e
      puts "❌ Ошибка: #{e.class} — #{e.message}"
    ensure
      puts "#{nickname} отключился"
      clients.delete(sock)
      sock.close
    end
  end  
end
```

##### client.rb

```ruby
require 'socket'

def read_tpkt(socket)
    header = socket.read(4)
    return nil unless header && header.bytesize == 4
    version, _, hi, lo = header.unpack("C4")
    length = (hi << 8) + lo
    payload = socket.read(length - 4)
    return nil if payload.nil?
    payload
  rescue IOError, EOFError, Errno::ECONNRESET
    nil
  end

def send_tpkt(socket, data)
  length = data.bytesize + 4
  header = [3, 0, length >> 8, length & 0xFF].pack("C4")
  socket.write(header + data)
end

socket = TCPSocket.new('192.168.100.90', 4000)
puts "Подключено к серверу. Пиши сообщения (или 'exit'):"

# Приём в отдельном потоке
Thread.new do
  loop do
    msg = read_tpkt(socket)
    break if msg.nil?
    puts "\n#{msg}"
    print "> "
  end
end

# Отправка из основного потока
loop do
  print "> "
  input = gets
  break if input.nil? || input.strip.downcase == "exit"
  send_tpkt(socket, input.chomp)
end

socket.close
puts "Отключено от сервера"
```

##### Терминал

Открой один терминал: `ruby server.rb`
Открой несколько других терминалов: `ruby client.rb`
Пиши сообщения — они будут отправлены всем другим клиентам.