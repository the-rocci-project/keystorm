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

    def encrypt(data)
      encipher = OpenSSL::Cipher.new(Rails.configuration.keystorm['token_cipher']).encrypt
      encipher.key = Rails.configuration.keystorm['token_key']
      encipher.iv  = Rails.configuration.keystorm['token_iv']
      encipher.update(data) + encipher.final
    end

    def decrypt(data)
      decipher = OpenSSL::Cipher.new(Rails.configuration.keystorm['token_cipher']).decrypt
      decipher.key = Rails.configuration.keystorm['token_key']
      decipher.iv  = Rails.configuration.keystorm['token_iv']
      decipher.update(data) + decipher.final
    end
  end
end
