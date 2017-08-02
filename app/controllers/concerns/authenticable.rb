module Authenticable
  extend ActiveSupport::Concern

  # Header token const
  TOKEN_HEADER_KEY = 'X-Auth-Token'.freeze

  class_methods do
    # Returns HTTP header key for token.
    #
    # @return [String] header key for token
    def token_header_key
      TOKEN_HEADER_KEY
    end
  end

  def validate_token_header!
    raise Errors::AuthenticationError, 'No token provided' unless request.headers.include? self.class.token_header_key
  end
end
