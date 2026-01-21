# server.rb
require 'socket'
# configuration
SERVER_IP="127.0.0.1"
SERVER_UDP_PORT=4913
BUFFER_SIZE=1024
BACON="there?"
BACON_NUMBER=3
REFRESH_RATE=1
# configuration

udp_socket = UDPSocket.new
udp_socket.bind(SERVER_IP, SERVER_UDP_PORT)
# Initialisation des variables de fonctionnement
clients = []
bacon_count = 0

loop do
    sleep REFRESH_RATE
    begin
        mesg, addr = udp_socket.recvfrom_nonblock(BUFFER_SIZE)
        if addr
            port = addr[1]
            host = addr[2]

            client = [host,port]
            clients << client unless clients.include? client
        end
    rescue
    end

    # Section bacon serveur
    if bacon_count > BACON_NUMBER
        clients.each do |client|
            udp_socket.send BACON, 0, client[0], client[1]
        end
        bacon_count = 0
        #clients = []
    end
    bacon_count += 1
    # Section bacon serveur

    clients.each do |client|
        udp_socket.send Time.now.to_s, 0, client[0], client[1]
    end

    # Affichage de la liste des clients a chaque loop
    p "------liste des clients-------"
    p clients
end