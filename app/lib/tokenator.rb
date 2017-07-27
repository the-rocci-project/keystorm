require 'json'
require 'base64'
require 'openssl'

class Tokenator
  class << self
    def to_token(hash)
      encrypt(Base64.encode64(hash.to_json))
    end

    def from_token(token)
      JSON.parse(Base64.decode64(decrypt(token)))
    end

    private

    def cipher(mode)
      raise ArgumentError, 'only support encrypt and decrypt modes' \
        unless %i[encrypt decrypt].include?(mode)

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
