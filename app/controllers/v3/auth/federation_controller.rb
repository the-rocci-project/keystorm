module V3
  module Auth
    class FederationController < ApplicationController
      include Auditable
      include Timestampable
      include TokenRespondable

      attr_reader :credentials

      after_action :audit_unscoped_token

      def oidc
        auth_response ::Auth::Oidc, 'OIDC'
      end

      def voms
        auth_response ::Auth::Voms, 'SSL', 'GRST'
      end

      private

      def auth_response(type, *filters)
        @credentials = type.unified_credentials(
          request.headers.env.each_with_object({}) do |(key, val), hash|
            matches = key.match(/(HTTP_)?(?<new_key>(#{filters.join('|')})[^\s]+)/)
            hash[matches[:new_key]] = val if matches
            hash
          end
        )
        set_header
        respond_with token_response
      end

      def set_header
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(credentials.to_hash)
      end
    end
  end
end
