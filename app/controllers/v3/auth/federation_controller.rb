module V3
  module Auth
    class FederationController < ApplicationController
      TIME_FORMAT = '%Y-%m-%dT%H:%M:%S.%L000Z'.freeze

      def oidc
        credentials = ::Auth::Oidc.unified_credentials(ENV.select { |name| name.start_with?('OIDC') })
        headers['X-Subject-Token'] = ::Tokenator.to_token(credentials.to_hash)
        render json: response_hash(credentials, 'oidc')
      end

      def voms
        credentials = ::Auth::Voms.unified_credentials(ENV.select { |name| name.start_with?('GRST', 'SSL') })
        headers['X-Subject-Token'] = ::Tokenator.to_token(credentials.to_hash)
        render json: response_hash(credentials, 'voms')
      end

      private

      def response_hash(credentials, protocol)
        {
          token: {
            issued_at: Time.zone.now.strftime(TIME_FORMAT),
            methods: [protocol],
            audit_ids: [],
            expires_at: Time.zone.at(credentials.expiration.to_i).strftime(TIME_FORMAT),
            user: response_hash_user(credentials, protocol)
          }
        }
      end

      def response_hash_user(credentials, protocol)
        {
          domain: response_hash_domain,
          id: credentials.id,
          name: credentials.id,
          :'OS-FEDERATION' => response_hash_fed(credentials, protocol)
        }
      end

      def response_hash_domain
        {
          id: 'Federated',
          name: 'Federated'
        }
      end

      def response_hash_fed(credentials, protocol)
        {
          identity_provider: {
            id: 'egi.eu'
          },
          protocol: {
            id: protocol
          },
          groups: credentials.groups
        }
      end
    end
  end
end
