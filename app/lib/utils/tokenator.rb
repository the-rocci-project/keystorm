require 'json'
require 'base64'
require 'openssl'

module Utils
  class Tokenator
    class << self
      def to_token(hash)
        encrypt(Base64.strict_encode64(hash.to_json))
      rescue ArgumentError, OpenSSL::Cipher::CipherError => ex
        raise Errors::AuthenticationError, "failed to tokenize hash: #{ex}"
      end

      def from_token(token)
        JSON.parse(Base64.strict_decode64(decrypt(token)))
      rescue ArgumentError, OpenSSL::Cipher::CipherError => ex
        raise Errors::AuthenticationError, "failed to parse data from token: #{ex}"
      end

      private

      def cipher(mode)
        raise ArgumentError, 'only support encrypt and decrypt modes' unless %i[encrypt decrypt].include?(mode)

        c     = OpenSSL::Cipher.new(Rails.configuration.keystorm['token_cipher']).send(mode)
        c.key = Rails.configuration.keystorm['token_key']
        c.iv  = Rails.configuration.keystorm['token_iv']
        c
      end

      def encrypt(data)
        encipher = cipher(:encrypt)
        encipher.update(data) + encipher.final
      end

      def decrypt(data)
        decipher = cipher(:decrypt)
        decipher.update(data) + decipher.final
      end
    end
  end
end
