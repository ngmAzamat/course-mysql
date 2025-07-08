require 'rb-readline'

loop do
  input = Readline.readline('> ', true)
  break if input.nil? || input.strip.downcase == 'exit'
  puts "Вы ввели: #{input.inspect}, кодировка: #{input.encoding}"
end