# frozen_string_literal: true

module Auth
  class Oidc
    include Expirable

    HEADERS_FILTERS = Rails.configuration.keystorm['behind_proxy'] ? %w[HTTP_OIDC].freeze : %w[OIDC].freeze

    OIDC_ID = 'OIDC_SUB'
    OIDC_EMAIL = 'OIDC_EMAIL'
    OIDC_GROUPS = 'OIDC_EDU_PERSON_ENTITLEMENTS'
    OIDC_NAME = 'OIDC_NAME'
    OIDC_IDENTITY = 'OIDC_SUB'
    OIDC_ISSUER = 'OIDC_ISS'
    OIDC_ACR = 'OIDC_ACR'
    REQUIRED_VARIABLES = [OIDC_ID, OIDC_GROUPS].freeze

    attr_reader :env

    def initialize(env)
      @env = env
    end

    def unified_credentials
      Rails.logger.debug { "Building OIDC unified credentials from #{hash.inspect}" }
      check_env!
      UnifiedCredentials.new(credential_args)
    end

    private

    def credential_args
      { id: env[OIDC_ID],
        email: env[OIDC_EMAIL],
        groups: parse_groups,
        authentication: { type: 'federation', method: 'oidc' },
        name: env[OIDC_NAME],
        identity: env[OIDC_IDENTITY],
        expiration: expiration,
        issuer: env[OIDC_ISSUER],
        acr: env[OIDC_ACR] }
    end

    def check_env!
      return if REQUIRED_VARIABLES.all? { |key| env.key?(key) }

      Rails.logger.error { "ENV variables does not contain #{REQUIRED_VARIABLES.reject { |var| env.key?(var) }}" }
      raise Errors::AuthenticationError, 'Invalid OIDC env variables set'
    end

    def parse_groups
      groups = Hash.new { |h, k| h[k] = [] }
      regexp = group_regexp
      env[OIDC_GROUPS].split(';').each do |line|
        matches = line.match(regexp)
        groups[matches[:group]] << matches[:role] if matches
      end
      normalize_and_filter_groups(groups)
    end

    def normalize_and_filter_groups(groups)
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
