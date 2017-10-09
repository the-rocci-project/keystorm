module Auth
  class Oidc
    extend Expirable

    HEADERS_FILTERS = Rails.configuration.keystorm['behind_proxy'] ? %w[HTTP_OIDC].freeze : %w[OIDC].freeze

    class << self
      OIDC_ID = 'OIDC_SUB'.freeze
      OIDC_EMAIL = 'OIDC_EMAIL'.freeze
      OIDC_GROUPS = 'OIDC_EDU_PERSON_ENTITLEMENTS'.freeze
      OIDC_NAME = 'OIDC_NAME'.freeze
      OIDC_IDENTITY = 'OIDC_SUB'.freeze
      OIDC_ISSUER = 'OIDC_ISS'.freeze
      OIDC_ACR = 'OIDC_ACR'.freeze
      REQUIRED_VARIABLES = [OIDC_ID, OIDC_GROUPS].freeze

      def unified_credentials(hash)
        Rails.logger.debug { "Building OIDC unified credentials from #{hash.inspect}" }
        check_hash!(hash)
        UnifiedCredentials.new(credential_args(hash))
      end

      private

      def credential_args(hash)
        { id: hash[OIDC_ID],
          email: hash[OIDC_EMAIL],
          groups: parse_hash_groups(hash),
          authentication: { type: 'federation', method: 'oidc' },
          name: hash[OIDC_NAME],
          identity: hash[OIDC_IDENTITY],
          expiration: expiration,
          issuer: hash[OIDC_ISSUER],
          acr: hash[OIDC_ACR] }
      end

      def check_hash!(hash)
        return if REQUIRED_VARIABLES.all? { |key| hash.key?(key) }
        Rails.logger.error { "ENV variables does not contain #{REQUIRED_VARIABLES.reject { |var| hash.key?(var) }}" }
        raise Errors::AuthenticationError, 'Invalid OIDC env variables set'
      end

      def parse_hash_groups(hash)
        groups = Hash.new { |h, k| h[k] = [] }
        regexp = group_regexp
        hash[OIDC_GROUPS].split(';').each do |line|
          matches = line.match(regexp)
          groups[matches[:group]] << matches[:role] if matches
        end
        Utils::GroupFilter.new.run!(groups)
        groups.map { |key, value| { id: key, roles: value.uniq } }
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
