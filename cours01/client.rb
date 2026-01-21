# client.rb
require 'socket'
# Configuration
BACON_IN="there?"
BACON_OUT="hi"
SERVER_IP="127.0.0.1"
SERVER_UDP_PORT=4913
BUFFER_SIZE = 1024
# Configuration

udp_socket = UDPSocket.new

msg=BACON_IN #initialise avec un bacon_in
nb=0

loop do
    if msg == BACON_IN
        udp_socket.send BACON_OUT, 0, SERVER_IP, SERVER_UDP_PORT
    end
    msg = udp_socket.recv(BUFFER_SIZE) #=> "there?" || timestamp

    # numérotation des paquets recus
    nb += 1
    p nb.to_s + " :" + msg
    #p msg
end