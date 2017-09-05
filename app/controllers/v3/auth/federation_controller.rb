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
        @credentials = type.unified_credentials(ENV.select { |name| name.start_with?(*filters) })
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(credentials.to_hash)
        respond_with token_response
      end
    end
  end
end
