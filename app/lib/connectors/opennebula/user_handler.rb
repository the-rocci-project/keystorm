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
        user_alloc = OpenNebula::User.build_xml
        user = OpenNebula::User.new(user_alloc, client)

        handle_opennebula_error do
          user.allocate(username, password, auth)
          user.chgrp group.id
          user.info
        end

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
        user_alloc = OpenNebula::User.build_xml
        user = OpenNebula::User.new(user_alloc, client)

        handle_opennebula_error { user.login(username, '', (expiration - Time.now.to_i), group.id) }
      end
    end
  end
end
