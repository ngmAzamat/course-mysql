# библиотеки
require 'socket'

# переменные
host = "127.0.0.1"
port = 3000
body = "Так мое имя Азамат!"


# подключаемся к серверу
socket = TCPSocket.new(host, port)

# формируем запрос
request = [
  "POST / HTTP/1.1", # также надо и в GET
  "Host: #{host}", # также надо и в GET
  "User-Agent: RubyTCP", # также надо и в GET
  "Accept: */*", # также надо и в GET
  "Content-Type: text/plain; charset=utf-8", # обязательный заголовок, в POST
  "Content-Length: #{body.bytesize}",  # обязательный заголовок, в POST
  "Connection: close", # также надо и в GET
  "",  # пустая строка завершает заголовки
].join("\r\n") + "\r\n" + body  # после заголовков тело

# отправляем запрос
socket.write(request)

# читаем запрос
response = socket.read
puts response

# закрываем соединение с сервером 
socket.close
