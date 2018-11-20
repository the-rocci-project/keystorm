# frozen_string_literal: true

module Connectors
  module Opennebula
    class UserHandler < Handler
      EXCLUDE = %w[oneadmin serveradmin].freeze

      def initialize
        super
        @pool = OpenNebula::UserPool.new client
      end

      def exclude
        self.class::EXCLUDE
      end

      alias list find_all

      def create(username, password, auth, group)
        user = OpenNebula::User.new(OpenNebula::User.build_xml, client)

        handle_opennebula_error { user.allocate(username, password, auth, [group.id]) }
        handle_opennebula_error { user.info }

        user
      end

      def add_group(user, group)
        return if user.groups.include? group.id

        handle_opennebula_error { user.addgroup group.id }
      end

      def update(user, template)
        handle_opennebula_error { user.update(template, true) }
      end

      def token(username, group, expiration)
        user = OpenNebula::User.new(OpenNebula::User.build_xml, client)

        handle_opennebula_error { user.login(username, '', (expiration.to_i - Time.now.to_i), group.id) }
      end

      def clean_tokens(user, group)
        user.each('LOGIN_TOKEN') do |token|
          handle_opennebula_error { user.login(user.name, token['TOKEN'], 0) } if token['EGID'].to_i == group.id
        end
      end
    end
  end
end
