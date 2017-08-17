module V3
  module Auth
    class FederationController < ApplicationController
      include Timestampable
      include TokenRespondable

      def oidc
        @credentials = ::Auth::Oidc.unified_credentials(ENV.select { |name| name.start_with?('OIDC') })
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(@credentials.to_hash)
        respond_with token_response
      end

      def voms
        @credentials = ::Auth::Voms.unified_credentials(ENV.select { |name| name.start_with?('GRST', 'SSL') })
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(@credentials.to_hash)
        respond_with token_response
      end
    end
  end
end
