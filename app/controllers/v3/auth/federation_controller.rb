module V3
  module Auth
    class FederationController < ApplicationController
      include Auditable
      include Timestampable
      include TokenRespondable

      attr_reader :credentials

      after_action :audit_unscoped_token

      def oidc
        auth_headers(::Auth::Oidc)
        respond_with token_response
      end

      def voms
        auth_headers(::Auth::Voms)
        respond_with token_response
      end

      private

      def auth_headers(type)
        @credentials = type.unified_credentials(unify_headers(type::HEADERS_FILTERS))
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(credentials.to_hash)
      end

      def unify_headers(filters)
        request.headers.env.each_with_object({}) do |(key, val), hash|
          hash[key.gsub(/^HTTP_/, '').upcase] = val if key.start_with?(*filters)
        end
      end
    end
  end
end
