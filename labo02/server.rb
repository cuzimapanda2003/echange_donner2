# server.rb
require 'socket'
#initialisation des variables
HOST = "localhost"
PORT = 2000
BUFFER_SIZE = 1024


serv = TCPServer.new(HOST, PORT)

clients={}

def ajouter_client(clients, client, nom) # ajoute au hash un client 
    clients[client] = nom.to_s
end


loop do

    begin # emulate blocking accept
        client = serv.accept_nonblock # recoit le client
        name = client.gets #recoit le nom du client
        ajouter_client(clients,client,name)
      #  puts clients # affiche le client

    rescue
    end

    clients.each do |client,nom| 
        begin
            msg = client.read_nonblock(BUFFER_SIZE) # recoit le message
            if msg
                msgWithName = "#{nom.chomp} a dit : #{msg}" #creer le message avec le nom
                p msgWithName
                
                clients.each do |client,nom|
                    premier_mot = msgWithName.split(' ').first # prends le nom de la personne qui envois le message
                    if premier_mot != nom.chomp # compare le nom des client si différent passe au suivant
                     client.puts msgWithName # envois le message au autre client
                    end
                end

            end
        rescue
        end

        begin
        msg = ""    
        client.puts msg
        rescue
            clients.delete(client)
        end
    end
end

clients.each do |client|
    client.close
end