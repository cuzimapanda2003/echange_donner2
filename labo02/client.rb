# client.rb
require 'socket'

HOST = "localhost"
PORT = 2000
BUFFER_SIZE = 1024
KEYBOARD_BUFFER = 1

socket = TCPSocket.new HOST, PORT
char = ''


puts "Veuillez rentrer votre nom : "
$nom = gets.chomp
socket.puts $nom


while line = socket.gets # Read lines from socket
    read=(STDIN.read_nonblock(KEYBOARD_BUFFER).chomp rescue nil) # accumulation des charactères dans un buffer variable
    if read
        char += read
    end

    if read == ''
        socket.write char
        char = ''
    end
    puts line unless line == "\n"      # and print them
end

s.close             # close socket when done

