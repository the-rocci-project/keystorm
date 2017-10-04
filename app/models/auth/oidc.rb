module Auth
  class Oidc
    extend Expirable

    HEADERS_FILTERS = Rails.configuration.keystorm['behind_proxy'] ? %w[HTTP_OIDC].freeze : %w[OIDC].freeze

    class << self
      REQUIRED_VARIABLES = %w[OIDC_sub OIDC_edu_person_entitlements].freeze

      def unified_credentials(hash)
        Rails.logger.debug { "Building OIDC unified credentials from #{hash.inspect}" }
        check_hash!(hash)
        UnifiedCredentials.new(credential_args(hash))
      end

      private

      def credential_args(hash)
        { id: hash['OIDC_sub'],
          email: hash['OIDC_email'],
          groups: parse_hash_groups(hash),
          authentication: { type: 'federation', method: 'oidc' },
          name: hash['OIDC_name'],
          identity: hash['OIDC_sub'],
          expiration: expiration,
          issuer: hash['OIDC_iss'],
          acr: hash['OIDC_acr'] }
      end

      def check_hash!(hash)
        raise Errors::AuthenticationError, "env variables does not contain #{REQUIRED_VARIABLES.reject { |var| hash.key?(var) }}" \
          unless REQUIRED_VARIABLES.all? { |key| hash.key?(key) }
      end

      def parse_hash_groups(hash)
        groups = Hash.new { |h, k| h[k] = [] }
        regexp = group_regexp
        hash['OIDC_edu_person_entitlements'].split(';').each do |line|
          matches = line.match(regexp)
          groups[matches[:group]] << matches[:role] if matches
        end
        groups.map { |key, value| { id: key, roles: value } }
      end

      def group_regexp
        Regexp.new(Rails.configuration.keystorm['oidc']['matcher']
                     .gsub(/\{role\}/, '(?<role>[^\s]+)')
                     .gsub(/\{group\}/, '(?<group>[^\s]+)')
                     .prepend('^')
                     .concat('$'))
      end
    end
  end
end
