# frozen_string_literal: true

module Connectors
  module Opennebula
    class GroupHandler < Handler
      EXCLUDE = %w[oneadmin users].freeze
      KEYSTORM_MANAGED_ATTRIBUTE = 'KEYSTORM'
      KEYSTORM_MANAGED_VALUE = 'YES'

      def initialize
        super
        @pool = OpenNebula::GroupPool.new client
      end

      def exclude
        self.class::EXCLUDE
      end

      def list
        find_all.select { |group| group["TEMPLATE/#{KEYSTORM_MANAGED_ATTRIBUTE}"] == KEYSTORM_MANAGED_VALUE }
      end
    end
  end
end
