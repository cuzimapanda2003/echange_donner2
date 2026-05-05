##
# Programme séquentiel de test de combinaison par force brute
# en testant toutes les permutations de caractères ASCII possibles
#

##
# Appel des librairie et fichier nécessaire au fonctionnement du code
#

require 'socket'
require 'json'
require 'benchmark'
require './Encodage.rb'

##
# Constante utiliser pour savoir le nombre de char dans la clef et 
# et la plage des valeurs ASCII (de 0 à 127 inclusivement)
#
NB_KEY_CHAR = 2
MIN_ASCII = 0
MAX_ASCII = 127

permutations = (MIN_ASCII..MAX_ASCII).to_a.permutation(NB_KEY_CHAR)

##Clef a 2 char
if NB_KEY_CHAR==2
    encrypted_message="212d26265d412513061708404737081414410617021b47050202081411041515472d224114040413021546"
end
##Clef a 3 char
if NB_KEY_CHAR==3
    encrypted_message="212d06205b67251326110e664737281212670617221d41230202281217221515672b246714042415043346"
end
##Clef a 4 char
if NB_KEY_CHAR==4
    encrypted_message="212d06215d410514061728474737281314412610021b67020202281311043512472d024614042414021566"
end

##
# Analyse séquentielle de toutes les permutations et mesure du temps d'exécution
#
time = Benchmark.realtime do
result = Encodage.work(encrypted_message, permutations)
puts result
end

puts "Block code took #{time} seconds."