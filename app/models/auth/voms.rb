require 'digest'

module Auth
  class Voms
    extend Expirable

    HEADERS_FILTERS = Rails.configuration.keystorm['behind_proxy'] ? %w[HTTP_SSL HTTP_GRST].freeze : %w[SSL GRST].freeze

    class << self
      VOMS_GROUP_REGEXP = %r{^\/(?<group>[^\s]+)\/Role=(?<role>[^\s]+)\/Capability=(?<capability>[^\s]+)$}

      def unified_credentials(hash)
        Rails.logger.debug { "Building VOMS unified credentials from #{hash.inspect}" }
        dn = parse_hash_dn!(hash)
        UnifiedCredentials.new(id: Digest::SHA256.hexdigest(dn),
                               groups: parse_hash_groups!(hash),
                               authentication: { type: 'federation', method: 'voms' },
                               name: dn,
                               identity: dn,
                               expiration: expiration)
      end

      private

      def parse_hash_dn!(hash)
        hash.select { |key| /GRST_CRED_\d+/ =~ key }.each_value do |cred|
          matches = cred.match(/^X509USER (\d+) (\d+) (\d+) (?<dn>.+)$/)
          return matches[:dn] if matches
        end
        raise Errors::AuthenticationError, 'failed to parse dn from env variables'
      end

      def parse_hash_groups!(hash)
        raise Errors::AuthenticationError, 'voms group env variable is not set' unless hash.key?('GRST_VOMS_FQANS')
        groups = Hash.new { |h, k| h[k] = [] }
        hash['GRST_VOMS_FQANS'].split(';').each do |line|
          group = parse_group!(line)
          groups.merge!(group) { |_, oldval, newval| oldval + newval } if group
        end
        Utils::GroupFilter.new.run!(groups)
        groups.map { |key, value| { id: key, roles: value.uniq } }
      end

      def parse_group!(line)
        matches = line.match(VOMS_GROUP_REGEXP)
        raise Errors::AuthenticationError, 'voms group env variable has invalid format' unless matches
        if matches[:group].include?('/')
          Rails.logger.warn { "Ignoring matched VOMS subgroup: #{matches[:group]}" }
          return
        end
        matches[:role] == 'NULL' ? { matches[:group] => [] } : { matches[:group] => [matches[:role]] }
      end
    end
  end
end
