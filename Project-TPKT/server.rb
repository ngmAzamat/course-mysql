require 'socket'

clients = []

def read_tpkt(socket)
  header = socket.read(4)
  return nil unless header && header.bytesize == 4
  version, _, hi, lo = header.unpack("C4")
  length = (hi << 8) + lo
  payload = socket.read(length - 4)
  return nil if payload.nil?

  # Корректно задаём UTF-8
  payload.force_encoding('UTF-8')
  unless payload.valid_encoding?
    payload = payload.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
  end

  payload
rescue EOFError, Errno::ECONNRESET, Errno::EPIPE
  nil
end

def send_tpkt(socket, data)
  data = data.encode('UTF-8')
  length = data.bytesize + 4
  header = [3, 0, length >> 8, length & 0xFF].pack("C4")
  socket.write(header + data)
rescue
  # Ошибка при отправке — игнорируем
end

server = TCPServer.new('0.0.0.0', 4000)
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

        msg = msg.force_encoding('UTF-8') if msg
        unless msg.valid_encoding?
          msg = msg.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '?')
        end

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
    ensure
      puts "#{nickname} отключился"
      clients.delete(sock)
      sock.close
    end
  end
end
