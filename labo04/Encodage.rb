##
# Classe permettant l'encodage et le décodage XOR utilisant une clef d'encryption variable seul ou en lot
#
class Encodage
    ##
    # Encrypte un message
    #
    # Message(String): Message à encrypter
    #
    # Key(String): Clef d'encryption
    #
    # Return(String): Le message encrypté
    #
    def self.encrypt(message, key)
        # Convertir le message en tableau d'octets
        message_bytes = message.bytes
        key_bytes = key.bytes
        encrypted_bytes = []

        # Appliquer XOR à chaque octet du message avec l'octet correspondant de la clé
        message_bytes.each_with_index do |byte, i|
          key_byte = key_bytes[i % key.length] # pour répéter la clé si elle est plus courte que le message
          encrypted_bytes << (byte ^ key_byte)
        end

        # Convertir les octets chiffrés en une chaîne hexadécimale
        encrypted_hex = encrypted_bytes.map { |b| sprintf('%02x', b) }.join
        return encrypted_hex
      end

      ##
      # Décrypte un message
      #
      # encrypted_message(String): Message encrypter
      #
      # Key(String): Clef d'encryption
      #
      # Return(String): Le message décrypté
      #
      def self.decrypt(encrypted_message, key)
        # Convertir la chaîne hexadécimale en tableau d'octets chiffrés
        encrypted_bytes = encrypted_message.scan(/../).map { |x| x.hex }
        key_bytes = key.bytes
        decrypted_bytes = []

        # Appliquer XOR à chaque octet chiffré avec l'octet correspondant de la clé
        encrypted_bytes.each_with_index do |byte, i|
          key_byte = key_bytes[i % key.length] # pour répéter la clé si elle est plus courte que le message
          decrypted_bytes << (byte ^ key_byte)
        end

        # Convertir les octets déchiffrés en une chaîne de caractères
        decrypted_message = decrypted_bytes.pack('C*')
        return decrypted_message
      end

      ##
      # Décrypte un lot de clef et vérifie si le message décrypté commence par "FLAG"
      #
      # Permet de réduire le nombre de faux positif
      #
      # encrypted_message(String): Message encrypter
      #
      # load_array(Array): Un tableau de clef d'encryption à évaluer (Ce tableau doit contenir les CODE ASCII)
      #
      # Return(Array): Un tableau de structure {"clef": "Message décrypté"}
      #
      def self.work encrypted_message="", load_array=[]

        keys_founded=[]

        load_array.each do |keys|
            key=keys.map(&:chr).join
            decrypted_message = decrypt(encrypted_message, key)
            if decrypted_message.start_with?("FLAG")
                keys_founded << {"#{key}": "#{decrypted_message}"}
                # Décommentez pour des fin de déboggage seulement
                #puts "Clef: #{key}  Message: #{decrypted_message}"
            end
        end
        return keys_founded
      end
end