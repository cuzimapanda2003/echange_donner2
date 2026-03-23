# server.rb
require 'socket'
# Attention binding.irb trap le control+c, on doit kill le process
serv = TCPServer.new("localhost", 2000)

clients=[]

loop do
    sleep 1 # Reduit la boucle d'envoi pour réduire la charge du processus
    begin # emulate blocking accept
        client = serv.accept_nonblock
        clients << client
    rescue
    end

    clients.each do |client|
        begin
            msg = client.read_nonblock(1024)
            if msg
                p "message du client :" + msg
            end
        rescue
        end

        begin
        client.puts Time.now
        rescue
            clients.delete(client)
        end
    end
end

clients.each do |client|
    client.close
end