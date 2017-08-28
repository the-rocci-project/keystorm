require 'digest'

module Auth
  class Voms
    class << self
      VOMS_GROUP_REGEXP = %r{^\/(?<group>[^\s]+)\/Role=(?<role>[^\s]+)\/Capability=NULL$}

      def unified_credentials(hash)
        Rails.logger.debug { "Building VOMS unified credentials from #{hash.inspect}" }
        dn = parse_hash_dn!(hash)
        UnifiedCredentials.new(id: Digest::SHA256.hexdigest(dn),
                               email: Rails.configuration.keystorm['voms']['default_email'],
                               groups: parse_hash_groups!(hash),
                               authentication: { type: 'federation', method: 'voms' },
                               name: dn,
                               identity: dn,
                               expiration: parse_hash_exp!(hash))
      end

      private

      def parse_hash_dn!(hash)
        hash.select { |key| /GRST_CRED_\d+/ =~ key }.each_value do |cred|
          matches = cred.match(/^X509USER (\d+) (\d+) (\d+) (?<dn>.+)$/)
          return matches[:dn] if matches
        end
        raise Errors::AuthenticationError, 'failed to parse dn from env variables'
      end

      def parse_hash_exp!(hash)
        hash.select { |key| /GRST_CRED_\d+/ =~ key }.each_value do |cred|
          matches = cred.match(/^VOMS (\d+) (?<expiration>\d+) (\d+) (.+)$/)
          return matches[:expiration] if matches
        end
        raise Errors::AuthenticationError, 'failed to parse expiration from env variables'
      end

      def parse_hash_groups!(hash)
        raise Error::AuthenticationError, 'voms group env variable is not set' unless hash.key?('GRST_VOMS_FQANS')
        groups = Hash.new { |h, k| h[k] = [] }
        hash['GRST_VOMS_FQANS'].split(';').each do |line|
          matches = line.match(VOMS_GROUP_REGEXP)
          groups[matches[:group]] << matches[:role] if matches && matches[:role] != 'NULL'
        end
        groups.map { |key, value| { id: key, roles: value } }
      end
    end
  end
end
