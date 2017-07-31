module Auth
  class Oidc
    class << self
      def unified_credentials(hash)
        check_hash!(hash)
        UnifiedCredentials.new(id: hash['OIDC_sub'],
                               email: hash['OIDC_email'],
                               groups: parse_hash_groups(hash),
                               authentication: 'federation',
                               name: hash['OIDC_name'],
                               identity: hash['OIDC_sub'],
                               expiration: hash['OIDC_access_token_expires'],
                               issuer: hash['OIDC_iss'],
                               acr: hash['OIDC_acr'])
      end

      private

      def check_hash!(hash)
        raise AuthError, 'invalid oidc credential hash' \
          unless %w[OIDC_sub
                    OIDC_email
                    OIDC_edu_person_entitlements
                    OIDC_access_token_expires
                    OIDC_name
                    OIDC_iss
                    OIDC_acr].all? { |key| hash.key?(key) }
      end

      def parse_hash_groups(hash)
        groups = Hash.new([])
        hash['OIDC_edu_person_entitlements']
          .scan(group_regexp)
          .uniq
          .each { |pair| groups[pair[1]] += [pair[0]] }
        groups
      end

      def group_regexp
        Regexp.new(Rails.configuration.keystorm['oidc']['matcher']
                     .gsub(/\{role\}/, '(\w*)')
                     .gsub(/\{group\}/, '([\w\.]*)'))
      end
    end
  end
end
