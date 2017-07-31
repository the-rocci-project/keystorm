require 'digest'

module Auth
  class Voms
    class << self
      def unified_credentials(hash)
        dn = parse_hash_dn!(hash)
        UnifiedCredentials.new(id: Digest::SHA256.hexdigest(dn),
                               email: Rails.configuration.keystorm['voms']['default_email'],
                               groups: parse_hash_groups!(hash),
                               authentication: 'federation',
                               name: dn,
                               identity: dn,
                               expiration: parse_hash_exp!(hash))
      end

      private

      def parse_hash_dn!(hash)
        x509cred = hash.select { |key, value| /GRST_CRED_\d+/ =~ key && value.start_with?('X509USER') }
        raise Errors::AuthError, 'voms hash has invalid X509USER "GRST_CRED_*" variable set' unless x509cred.size == 1
        parsed = x509cred.values.first.split(' ', 5)
        raise Errors::AuthError, 'failed to parse DN from voms hash' unless parsed.size == 5
        parsed[4]
      end

      def parse_hash_exp!(hash)
        vomscred = hash.select { |key, value| /GRST_CRED_\d+/ =~ key && value.start_with?('VOMS') }
        raise Errors::AuthError, 'voms hash has invalid VOMS "GRST_CRED_*" variable set' unless vomscred.size == 1
        parsed = vomscred.values.first.split(' ')
        raise Errors::AuthError, 'failed to parse DN from voms hash' unless parsed.size >= 3
        parsed[2]
      end

      def parse_hash_groups!(hash)
        raise Error::AuthError, 'voms group env variable is not set' unless hash.key?('GRST_VOMS_FQANS')
        groups = Hash.new([])
        hash['GRST_VOMS_FQANS'].scan(%r{([\w\.]*)\/Role=(\w*)\/Capability=NULL})
                               .uniq
                               .each { |pair| groups[pair[0]] += [pair[1]] }
        groups
      end
    end
  end
end
