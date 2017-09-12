module V3
  module Auth
    class FederationController < ApplicationController
      include Auditable
      include Timestampable
      include TokenRespondable

      attr_reader :credentials

      after_action :audit_unscoped_token

      OIDC_FILTERS = %w[OIDC].freeze
      VOMS_FILTERS = %w[SSL GRST].freeze

      def oidc
        set_auth_headers(::Auth::Oidc, unify_headers(OIDC_FILTERS))
        respond_with token_response
      end

      def voms
        set_auth_headers(::Auth::Voms, unify_headers(VOMS_FILTERS))
        respond_with token_response
      end

      private

      def set_auth_headers(type, auth_hash)
        @credentials = type.unified_credentials(auth_hash)
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(credentials.to_hash)
      end

      def unify_headers(filters)
        filters = filters.map { |filter| 'HTTP_' + filter } if Rails.configuration.keystorm['behind_proxy']
        request.headers.env.each_with_object({}) do |(key, val), hash|
          hash[key.gsub(/^HTTP_/, '')] = val if key.start_with?(*filters)
        end
      end
    end
  end
end
