module Auth
  class Oidc
    HEADERS_FITLERS = Rails.configuration.keystorm['behind_proxy'] ? %w[HTTP_OIDC].freeze : %w[OIDC].freeze

    class << self
      ENV_NAMES = {
        id: 'OIDC_sub',
        email: 'OIDC_email',
        groups: 'OIDC_edu_person_entitlements',
        name: 'OIDC_name',
        identity: 'OIDC_sub',
        expiration: 'OIDC_access_token_expires',
        issuer: 'OIDC_iss',
        acr: 'OIDC_acr'
      }.freeze

      def unified_credentials(hash)
        Rails.logger.debug { "Building OIDC unified credentials from #{hash.inspect}" }
        check_hash!(hash)
        uc_hash = ENV_NAMES.map { |key, value| [key, hash[value]] }.to_h
        uc_hash[:authentication] = { type: 'federation', method: 'oidc' }
        uc_hash[:groups] = parse_hash_groups(hash)
        UnifiedCredentials.new(uc_hash)
      end

      private

      def check_hash!(hash)
        raise Errors::AuthenticationError, 'invalid oidc credential hash' \
          unless ENV_NAMES.values.all? { |key| hash.key?(key) }
      end

      def parse_hash_groups(hash)
        groups = Hash.new { |h, k| h[k] = [] }
        regexp = group_regexp
        hash[ENV_NAMES[:groups]].split(';').each do |line|
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
