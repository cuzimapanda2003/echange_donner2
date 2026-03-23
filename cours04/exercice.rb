# Variable partagée entre les threads
@counter = 0

threads = []
@mutex = Thread::Mutex.new

# Méthode pour incrémenter le compteur de façon non sécurisée
def increment_counter_unsafe
    
    sleep(5)

    @mutex.synchronize do
        if @counter < 100
        # Simule une latence entre la lecture et l'écriture
            sleep(rand(0.001..0.01))
            @counter += 1
            puts "Incrément de 1"
        end
    end

end


(1..1000).each do | i |
    threads << Thread.new do
            increment_counter_unsafe
    end
end

threads.each { |thr| thr.join }
puts "Valeur finale du compteur : #{@counter}"