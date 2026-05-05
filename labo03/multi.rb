require 'net/http'
require 'json'
require 'benchmark'

time = Benchmark.realtime do

uri = URI('https://pokeapi.co/api/v2/pokemon/')
params = { :limit => 40, :offset => 0 } # Ajuster la limite pour 40 afin de valider le laboratoire
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
pokemons = JSON.parse(res.body)["results"].map{|po| po["name"]} if res.is_a?(Net::HTTPSuccess)

@registre=[]
threads = []
@mutex = Thread::Mutex.new


# Ajout du pokemon directement au bon endroit
def add_pokemon_to_local(pokemon, category)
  # Recherche de l'index ou insérer le pokemon
  insert_at = 0

    # Vous devez réaliser cette section
    # AUCUN TRI A FAIRE, Vous devez insérer judicieusement dans le tableau du registre
    # directement au bon endroit via la variable "insert_at"
  
      while insert_at < @registre.length && (@registre[insert_at] < pokemon)
        insert_at += 1
      end

      # Recherche de l'index ou insérer le pokemon
    sleep (rand(3)) # Ce sleep DOIT rester avant l'insertion du data dans le tableau
    @registre.insert(insert_at, "#{pokemon} - #{category}")
end

# Recuperation des informations des pokemons
def get_pokemon_category pokemon
    sleep (rand(9))
    uri = URI("https://pokeapi.co/api/v2/pokemon/#{pokemon}")
    uri.query = URI.encode_www_form({})

    res = Net::HTTP.get_response(uri)
    return JSON.parse(res.body)["types"].first["type"]["name"] if res.is_a?(Net::HTTPSuccess)
end



pokemons.each do |poke|
  threads << Thread.new do
    category = get_pokemon_category(poke)
    @mutex.synchronize do
      add_pokemon_to_local(poke, category)
    end
  end
end

  threads.each { |thr| thr.join }


@registre.each do |poke|
  puts poke
end


end

puts "Block code took #{time} seconds."