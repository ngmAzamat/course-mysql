# encoding: utf-8
require 'socket'         # для подключения к TCP-серверу
require 'readline'       # для красивого ввода строк (с историей)
require 'rb-readline'    # альтернативная реализация Readline, если system readline не поддерживает кириллицу

# Приём TPKT-пакета от сервера
def read_tpkt(socket)
  header = socket.read(4)                      # читаем 4 байта заголовка в header
  return nil unless header && header.bytesize == 4

  version, _, hi, lo = header.unpack("C4")     # разбираем заголовок
  length = (hi << 8) + lo                      # вычисляем длину пакета
  payload = socket.read(length - 4)            # читаем оставшуюся часть (полезную нагрузку)
  return nil if payload.nil?

  payload.force_encoding('UTF-8')              # задаём кодировку
  payload.valid_encoding? ? payload : payload.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
rescue => e # если у нас проблема то ошибка это e
  puts "Ошибка при приёме: #{e}" # и да если она есть то мы ее выводим
  nil
end

# Отправка TPKT-пакета на сервер | эту функцию не понимаю
def send_tpkt(socket, data)

  # мы делаем UTF-8
  data = if data.encoding == Encoding::ASCII_8BIT # что не понятное пришло(например кирилица)
    data.force_encoding("UTF-8") # о да это кирилица, прочитай ее как UTF-8
  else # пришло что то понятное
    data.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?") # сделай это UTF-8(если это еще не)! а иначе в ?
  end

  # Делаем сообщение
  length = data.bytesize + 4 # длинна данных = информация + 4 байта это длинна в байтах
  header = [3, 0, length >> 8, length & 0xFF].pack("C4") # наш header это версия(3) резервный байт(0) байты длинны(length >> 8, length & 0xFF) и они упаковываются
  packet = header + data # сообщение = заголовок + информация

  # отпровляем сообщение
  total_written = 0 
  while total_written < packet.bytesize # иногда из-за длинны мы не можем отправить все сразу и мы повторяем пока все не отправим
    written = socket.write(packet.byteslice(total_written, packet.bytesize - total_written))
    break if written.nil? || written == 0
    total_written += written
  end
rescue => e # если у нас проблема то ошибка это e
  puts "Ошибка при отправке: #{e}" # и да если она есть то мы ее выводим
end

# Подключение к серверу
socket = TCPSocket.new('127.0.0.1', 4000) # прокладываем канал к серверу со стороны клиента
puts "Подключено к серверу. Пиши сообщения (или 'exit'):" # все начинаем писать и логируем

# Thread to receive messages from server asynchronously
# Поток для асинхронного чтения сообщений от сервера
Thread.new do
  loop do # бесконечный цикл
    msg = read_tpkt(socket) # что это
    break if msg.nil? # что это

    current_input = Readline.line_buffer.to_s # что это

    # Clear current line and move to start
    print "\r\e[0K"          # очищаем текущую строку в терминале
    puts msg                 # печатаем сообщение от сервера

    # Restore prompt and user input
    print "> #{current_input}" # возвращаем приглашение и ввод
    $stdout.flush # принудительно выводим все
  end
end

# Основной цикл ввода
loop do # бесконечный цикл
  input = Readline.readline("> ", true) # что это
  break if input.nil? || input.strip.downcase == "exit" # что это

  send_tpkt(socket, input) # отправляем данные в функцию которая отправляет на сервер
end

socket.close # если цикл прекратился ио мы разрывает соединение
puts "Отключено от сервера" # и логируем это
