# frozen_string_literal: true

require 'json'
require 'base64'
require 'openssl'

module Utils
  class Tokenator
    class << self
      def to_token(data)
        raise ArgumentError, 'cannot tokenize nil' unless data

        msg = data.is_a?(String) ? data : data.to_json
        Rails.logger.debug { "Tokenizing data #{msg.inspect}" }
        token = Base64.strict_encode64(encrypt(msg))
        Rails.logger.debug { "Token: #{token.inspect}" }

        token
      rescue ArgumentError, OpenSSL::Cipher::CipherError => ex
        raise Errors::AuthenticationError, "failed to tokenize data: #{ex}"
      end

      def from_token(token, parse: true)
        raise ArgumentError, 'cannot parse token data from nil' unless token

        Rails.logger.debug { "Detokenizing data #{token.inspect}" }
        data = decrypt(Base64.strict_decode64(token))
        Rails.logger.debug { "Data: #{data.inspect}" }

        return data unless parse

        parse_data data
      rescue ArgumentError, OpenSSL::Cipher::CipherError => ex
        raise Errors::AuthenticationError, "failed to parse data from token: #{ex}"
      end

      private

      def parse_data(data)
        Rails.logger.debug { "Parsing data #{data.inspect} as JSON" }
        JSON.parse(data).deep_symbolize_keys
      end

      def cipher(mode)
        raise ArgumentError, 'only support encrypt and decrypt modes' unless %i[encrypt decrypt].include?(mode)

        c     = OpenSSL::Cipher.new(Rails.configuration.keystorm['token_cipher']).send(mode)
        c.key = Rails.configuration.keystorm['token_key']
        c.iv  = Rails.configuration.keystorm['token_iv']
        c
      end

      def encrypt(data)
        crypt data, :encrypt
      end

      def decrypt(data)
        crypt data, :decrypt
      end

      def crypt(data, mode)
        c = cipher(mode)
        Rails.logger.debug { "#{mode.capitalize}ing data with #{c.name.inspect} cipher" }
        c.update(data) + c.final
      end
    end
  end
end
