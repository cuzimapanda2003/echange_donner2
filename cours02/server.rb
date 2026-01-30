# server.rb
require 'socket'
# configuration
SERVER_IP="127.0.0.1"
SERVER_UDP_PORT=4913
BUFFER_SIZE=1024
BACON="there?"
BACON_NUMBER=3
REFRESH_RATE=1
BACON_RETRY=3
# configuration

udp_socket = UDPSocket.new
udp_socket.bind(SERVER_IP, SERVER_UDP_PORT)
# Initialisation des variables de fonctionnement
clients = []
bacon_count = 0

loop do


end