module Clouds
  class Opennebula
    attr_reader :group_handler, :user_handler

    def initialize
      @group_handler = Connectors::Opennebula::GroupHandler.new
      @user_handler = Connectors::Opennebula::UserHandler.new
    end

    def projects
      group_handler.list.map(&:name)
    end

    def autocreate(credentials, groupname)
      group = group_handler.find_by_name(groupname)
      user = user_handler.find_by_name(credentials.id)
      unless user
        user = user_handler.create(credentials.id, credentials.identity, 'remote', group)
        user_handler.update(user, user_template(credentials))
      end

      user_handler.add_group(user, group)
    end

    def token(username, groupname, expiration)
      group = group_handler.find_by_name(groupname)
      user_handler.token(username, group, expiration)
    end

    private

    def user_template(credentials)
      hash = credentials.to_hash
      hash[:authentication] = hash[:authentication][:method]
      hash.delete :groups

      hash.map { |key, value| "\"#{key.upcase}\" = \"#{value}\"" }.join("\n")
    end
  end
end
