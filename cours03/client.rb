# client.rb
require 'socket'

socket = TCPSocket.new 'localhost', 2000
char = ''

while line = socket.gets # Read lines from socket
    read=(STDIN.read_nonblock(1).chomp rescue nil) # accumulation des charactères dans un buffer variable
    if read
        char += read
    end

    if read == ''
        socket.write "client send: " + char
        char = ''
    end
    puts line         # and print them
end

s.close             # close socket when done