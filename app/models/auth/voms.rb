# frozen_string_literal: true

require 'digest'

module Auth
  class Voms
    include Expirable

    HEADERS_FILTERS = Rails.configuration.keystorm['behind_proxy'] ? %w[HTTP_SSL HTTP_GRST].freeze : %w[SSL GRST].freeze

    DN_MATCHER = /^X509USER (\d+) (\d+) (\d+) (?<dn>.+)$/.freeze
    DN_ROBOT_MATCHER = /^GSIPROXY (\d+) (\d+) (\d+) (?<dn>.+)$/.freeze
    VOMS_GROUP_REGEXP = %r{^\/(?<group>[^\s]+)\/Role=(?<role>[^\s]+)\/Capability=(?<capability>[^\s]+)$}.freeze

    ROBOT_KEY = 'GRST_ROBOT_DN'
    DN_KEY = 'GRST_CRED_0'
    DN_ROBOT_KEY = 'GRST_CRED_1'
    GROUPS_KEY = 'GRST_VOMS_FQANS'
    SSL_VERIFY = 'SSL_CLIENT_VERIFY'

    attr_reader :env, :pusp

    def initialize(env)
      @env = env
      @pusp = Utils::Pusp.new
    end

    def unified_credentials
      Rails.logger.debug { "Building VOMS unified credentials from #{env.inspect}" }
      verify!
      dn = find_dn!
      UnifiedCredentials.new(id: Digest::SHA256.hexdigest(dn),
                             groups: parse_groups!,
                             authentication: { type: 'federation', method: 'voms' },
                             name: dn,
                             identity: dn,
                             expiration: expiration)
    end

    private

    def verify!
      raise Errors::AuthenticationError, 'SSL not verified' \
        unless env[SSL_VERIFY] == 'SUCCESS'
    end

    def robot?
      env.key?(ROBOT_KEY)
    end

    def find_dn!
      if robot?
        return parse_dn!(DN_ROBOT_KEY, DN_ROBOT_MATCHER) if pusp.allowed?(env[ROBOT_KEY])
      end
      parse_dn!(DN_KEY, DN_MATCHER)
    end

    def parse_dn!(key, matcher)
      matches = env[key].match(matcher)
      return matches[:dn] if matches
      raise Errors::AuthenticationError, "failed to parse dn from #{key}" unless matches
    end

    def parse_groups!
      raise Errors::AuthenticationError, 'voms group env variable is not set' unless env.key?(GROUPS_KEY)

      groups = Hash.new { |h, k| h[k] = [] }
      env[GROUPS_KEY].split(';').each do |line|
        group = parse_group!(line)
        groups.merge!(group) { |_, oldval, newval| oldval + newval } if group
      end
      normalize_and_filter_groups(groups)
    end

    def normalize_and_filter_groups(groups)
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
