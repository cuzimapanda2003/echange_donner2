class Bank

    def initialize 
        @solde = 0
    end

    def retrait 
        retrait = rand(0..50) 
        if retrait <= @solde
        @solde -= retrait
        else
        puts "Vous n'avez pas assez d'argent"
        end
        puts @solde
    end

    def depot 
        sleep(rand(0..6))
        @solde += rand(0..100)
        puts @solde
    end

    def balance 
        puts @solde
    end

end

b = Bank.new

b.retrait
b.depot
b.retrait
b.balance

