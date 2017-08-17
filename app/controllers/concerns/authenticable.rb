module Authenticable
  extend ActiveSupport::Concern

  # Header token const
  X_AUTH_TOKEN_HEADER_KEY = 'X-Auth-Token'.freeze
  X_SUBJECT_TOKEN_HEADER_KEY = 'X-Subject-Token'.freeze

  class_methods do
    # Returns HTTP header key for token.
    #
    # @return [String] header key for token
    def x_auth_token_header_key
      X_AUTH_TOKEN_HEADER_KEY
    end

    def x_subject_token_header_key
      X_SUBJECT_TOKEN_HEADER_KEY
    end
  end

  delegate :x_auth_token_header_key, to: :class
  delegate :x_subject_token_header_key, to: :class

  def validate_token_header!
    raise Errors::AuthenticationError, 'No token provided' unless request.headers.include? x_auth_token_header_key
  end
end
