require 'json'
require 'base64'
require 'openssl'

module Utils
  class Tokenator
    class << self
      def to_token(data)
        raise ArgumentError, 'cannot tokenize nil' unless data
        msg = data.is_a?(String) ? data : data.to_json
        Base64.strict_encode64(encrypt(msg))
      rescue ArgumentError, OpenSSL::Cipher::CipherError => ex
        raise Errors::AuthenticationError, "failed to tokenize data: #{ex}"
      end

      def from_token(token, parse: true)
        raise ArgumentError, 'cannot parse token data from nil' unless token
        data = decrypt(Base64.strict_decode64(token))
        return data unless parse
        JSON.parse(data).deep_symbolize_keys
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
