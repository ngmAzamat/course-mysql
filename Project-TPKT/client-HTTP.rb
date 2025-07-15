require 'socket' # всегда для работы с TCP

host = "127.0.0.1" # host
port = 8000 # port

socket = TCPSocket.new(host,port) # подключение к серверу

# состовляем запрос на сервер
request = [
  "GET / HTTP/1.1",
  "Host: #{host}",
  "User-Agent: RubyTCP",
  "Accept: */*",
  "Connection: close",
  "",               # пустая строка завершает заголовки после нее будет тело
  ""
].join("\r\n")


# отпровляем запрос
socket.write(request)

# читаем и печатаем запрос
response = socket.read(1024)
puts response

# закрытие запроса
socket.close