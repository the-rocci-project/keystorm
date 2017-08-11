module Clouds
  class Opennebula
    def projects
      Connectors::Opennebula::GroupHandler.new.list.map(&:name)
    end

    # def create_user(username, groupname); end
    #
    # def token(username, groupname); end
  end
end
