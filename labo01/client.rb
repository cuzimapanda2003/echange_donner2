# client.rb
require 'socket'
require 'json'
# Configuration
BACON_IN="are you still watching?"
BACON_OUT="hello there"
SERVER_IP="127.0.0.1"
SERVER_UDP_PORT=4913
BUFFER_SIZE = 1024
REFRESH_RATE=1 # Attendre moins longtemps que le serveur pour constater l'accumulation sur le socket
TTL_TIME=2 # en secondes
# Configuration

udp_socket = UDPSocket.new
last_response = Time.now
msg=BACON_IN #initialise avec un bacon_in

$last_packet = nil

#afficher le message en json
def afficherJson(message)
    messageParse =  JSON.parse message, symbolize_name: true rescue {}
    return if messageParse.empty?
    return if $last_packet == messageParse
    $last_packet = messageParse
    puts "      information ordi       "
    puts "-----------------------------"
       messageParse.each do |key,value| 

        puts "#{key} => #{value} " 
       end
puts "-----------------------------"

end


loop do
    if msg == BACON_IN
        udp_socket.send BACON_OUT, 0, SERVER_IP, SERVER_UDP_PORT
        sleep REFRESH_RATE
    end

    #msg = udp_socket.recv(BUFFER_SIZE) #=> "there?" || timestamp
    # rejoindre le serveur si aucun signe de vie pendant...1 seconde?
    begin
        msg, addr = udp_socket.recvfrom_nonblock(BUFFER_SIZE)
        
       
        if addr
            last_response = Time.now
            #appel afficherjson
            afficherJson(msg)
            # numérotation des paquets recus
            # Prendre note que la numérotation devrait être fait sur le SERVEUR
        end
    rescue
    end

    msg=BACON_IN if last_response + TTL_TIME > Time.now

end