# server.rb
require 'socket'
require 'json'
# configuration
SERVER_IP="127.0.0.1"
SERVER_UDP_PORT=4913
BUFFER_SIZE=1024
BACON="are you still watching?"
BACON_NUMBER=3
REFRESH_RATE=1
BACON_RETRY=3
# configuration

udp_socket = UDPSocket.new
udp_socket.bind(SERVER_IP, SERVER_UDP_PORT)
# Initialisation des variables de fonctionnement
clients = []
bacon_count = 0
nb = 0

def get_computer_stats (nb)

#mémoier
mem_total = `free -mh |  awk '/Mem/ {print $(2)}'`
mem_used  = `free -mh |  awk '/Mem/ {print $(3)}'`
mem_free  = `free -mh |  awk '/Mem/ {print $(4)}'`

# espace disque
percent_used = `df -h / |  awk '/\\// {print $(5)}'`
disk_free    = `df -h / |  awk '/\\// {print $(4)}'`
disk_used    = `df -h / |  awk '/\\// {print $(3)}'`
disk_space   = `df -h / |  awk '/\\// {print $(2)}'`

#CPU LOAD

system_load  = `cat /proc/loadavg | awk '{print $1}'`

#hash ordi 
ordi = {
nombre_de_paquet: nb,
memoire_totale: mem_total.strip,
memoire_used: mem_used.strip,
memoire_free: mem_free.strip,
disck_percent_used: percent_used.strip,
disk_free: disk_free.strip,
disk_used: disk_used.strip,
disk_space: disk_space.strip,
system_load: system_load.strip
}

end

loop do
    sleep REFRESH_RATE
    begin
        mesg, addr = udp_socket.recvfrom_nonblock(BUFFER_SIZE)
        if addr
            port = addr[1]
            host = addr[2]

            client = [host,port]
            # Gestion du BACON_RETRY ---------------
            list_client=clients.detect{|i| [i[0],i[1]] == client }
            if(list_client)
                list_client[2] = 0
            else
                clients << [host,port, 0]
            end
        end
    rescue
    end

    # Section bacon serveur
    if bacon_count > BACON_NUMBER
        clients.each do |client|
            udp_socket.send BACON, 0, client[0], client[1]
            client[2] += 1
        end
        bacon_count = 0
    end
    bacon_count += 1
    nb+=1
    # Section bacon serveur

    clients.each do |client|
        # Gestion du BACON_RETRY ---------------
        if client[2] > BACON_RETRY
            clients.delete(client)
        else
            message_computer = get_computer_stats(nb)
            udp_socket.send message_computer.to_json, 0, client[0], client[1]
        end
    end


    p "------liste des clients-------"
    p clients


end