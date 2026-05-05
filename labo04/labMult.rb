##
# Appel des librairie et fichier necessaire au fonctionnement du code
#

require 'socket'
require 'json' 
require 'benchmark' 
require './Encodage.rb' 
require 'thread'

##
# Constante utiliser pour savoir le nombre de char dans la clef et 
# et la plage des valeurs ASCII
#
NB_KEY_CHAR = 2
MIN_ASCII = 0
MAX_ASCII = 127
BATCH_SIZE = 50000
NB_WORKERS = 24
SOCKET_NAME = 'socket'


`rm -f #{SOCKET_NAME}`

if NB_KEY_CHAR==2
    encrypted_message="212d26265d412513061708404737081414410617021b47050202081411041515472d224114040413021546"
end

if NB_KEY_CHAR==3
    encrypted_message="212d06205b67251326110e664737281212670617221d41230202281217221515672b246714042415043346"
end

if NB_KEY_CHAR==4
    encrypted_message="212d06215d410514061728474737281314412610021b67020202281311043512472d024614042414021566"
end
ENCRYPTED_MESSAGE = encrypted_message

@pids = []           # PIDs des forks
@workers = []        # Tableau de workers
@found_keys = []     # Resultats accumules
@nb_batch = 0        # Compteur de lots traites
@total_batch = 0     # Nombre total de lots
@mutex = Mutex.new   # Protection des acces concurrents

# retire le socket si il existe
`rm -f #{SOCKET_NAME}`

# demarrage du serveur
server = UNIXServer.new(SOCKET_NAME)


# trhead 1 accept connection des fork
# stock chaque socket dans @worker avec leur etat (0 = disponible)
Thread.new do
  begin
    loop do
      client = server.accept
      @workers << [client, 0]
    end
  rescue IOError
    # Serveur ferme, on quitte proprement
  end
end



# FORKS chaque worker se connecte, recoit des lots et retourne les resultats
NB_WORKERS.times do |i|
  @pids << fork do
    server.close  # Le fork n'a pas besoin du socket serveur
 
    socket = UNIXSocket.new(SOCKET_NAME)
 
    loop do
      line = socket.gets
      break if line.nil?
 
      batch = JSON.parse(line)
      break if batch.empty?  # Tableau vide = signal de fin
 
      results = Encodage.work(ENCRYPTED_MESSAGE, batch)
      socket.puts results.to_json
    end
 
    socket.close
  end
end
 
# Charger shutdown.rb APRES les forks pour ne pas dupliquer les Signal.trap
require './shutdown.rb'




# THREAD 2 lire les retours des workers occupes (etat == 1)
 
Thread.new do
  loop do
    # Chercher les workers occupes
    working = @workers.select { |w| w[1] == 1 }
 
    working.each do |worker|
      # Verifier si le socket est pret a lire sans bloquer
      if worker[0].wait_readable(0)
        data = worker[0].gets
        if data
          results = JSON.parse(data)
 
          @mutex.synchronize do
            @nb_batch += 1
            puts "lot ##{@nb_batch}/#{@total_batch} en cours"
 
            @found_keys.concat(results) unless results.empty?
          end
 
          worker[1] = 0  # Remettre disponible
        end
      end
    end
 
    sleep 0.001
  end
end


# Distribuer les lots aux workers disponibles

time = Benchmark.realtime do
  permutations = (MIN_ASCII..MAX_ASCII).to_a.repeated_permutation(NB_KEY_CHAR)
  batches      = permutations.each_slice(BATCH_SIZE)
  @total_batch = batches.size
 
  # Attendre que tous les workers soient connectes
  sleep 0.1 until @workers.size == NB_WORKERS
 
  work_to_do = true
 
  while work_to_do
    # Chercher un worker disponible
    available = @workers.select { |w| w[1] == 0 }
 
    available.each do |worker|
      begin
        worker[0].puts batches.next.to_json
        worker[1] = 1  # Marquer occupe
      rescue StopIteration
        work_to_do = false
        break
      end
    end
 
    sleep 0.001
  end
 
  # Attendre que tous les workers terminent leur dernier lot
  sleep 0.01 until @workers.all? { |w| w[1] == 0 }
 
  # Envoyer signal de fin (tableau vide) a chaque worker
  @workers.each do |worker|
    worker[0].puts [].to_json
    worker[0].close
  end
end
 
# Attendre la fin de tous les forks
@pids.each { |pid| Process.waitpid(pid) rescue nil }
 
server.close
`rm -f #{SOCKET_NAME}`


# Resume final
 
puts "\nVoici les clefs trouvées en #{time.round(2)} Secondes #{NB_WORKERS} Forks et #{BATCH_SIZE} clefs par lot:"
if @found_keys.empty?
  puts "(Aucune clef trouvée)"
else
  @found_keys.each { |k| puts k.to_s }
end