module Auth
  class Oidc
    def self.unified_credentials(hash)
      check_hash!(hash)
      UnifiedCredentials.new(id: hash['OIDC_sub'],
                             email: hash['OIDC_email'],
                             groups: hash['OIDC_edu_person_entitlements'],
                             authentication: 'federation',
                             name: hash['OIDC_name'],
                             identity: hash['OIDC_sub'],
                             expiration: hash['OIDC_access_token_expires'],
                             issuer: hash['OIDC_iss'],
                             acr: hash['OIDC_acr'])
    end

    def self.check_hash!(hash)
      raise Error, 'invalid oidc credential hash' \
        unless %w[OIDC_sub
                  OIDC_email
                  OIDC_edu_person_entitlements
                  OIDC_access_token_expires
                  OIDC_name
                  OIDC_iss
                  OIDC_acr].all? { |key| hash.key?(key) }
    end
  end
end
