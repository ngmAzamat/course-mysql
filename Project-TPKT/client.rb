require 'socket'
require 'readline'

def read_tpkt(socket)
  header = socket.read(4)
  return nil unless header && header.bytesize == 4
  version, _, hi, lo = header.unpack("C4")
  length = (hi << 8) + lo
  payload = socket.read(length - 4)
  return nil if payload.nil?

  payload.force_encoding('UTF-8')
  unless payload.valid_encoding?
    payload = payload.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
  end

  payload
rescue IOError, EOFError, Errno::ECONNRESET
  nil
end

def send_tpkt(socket, data)
  data = data.encode('UTF-8')
  length = data.bytesize + 4
  header = [3, 0, length >> 8, length & 0xFF].pack("C4")
  socket.write(header + data)
rescue
  # Игнорируем ошибки
end

socket = TCPSocket.new('127.0.0.1', 4000)
puts "Подключено к серверу. Пиши сообщения (или 'exit'):"

Thread.new do
  loop do
    msg = read_tpkt(socket)
    break if msg.nil?

    # Сохраняем текущую строку ввода
    current_input = Readline.line_buffer

    # Очищаем строку ввода и курсор
    print "\r#{' ' * (current_input.length + 2)}\r"

    puts msg

    # Восстанавливаем приглашение и строку ввода
    print "> #{current_input}"
    $stdout.flush
  end
end

loop do
  input = Readline.readline("> ", true)
  break if input.nil? || input.strip.downcase == "exit"
  send_tpkt(socket, input)
end

socket.close
puts "Отключено от сервера"
