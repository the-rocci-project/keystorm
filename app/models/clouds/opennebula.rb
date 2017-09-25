require 'digest'

module Clouds
  class Opennebula
    attr_reader :group_handler, :user_handler

    def initialize
      @group_handler = Connectors::Opennebula::GroupHandler.new
      @user_handler = Connectors::Opennebula::UserHandler.new
    end

    def projects
      Rails.logger.debug { 'Listing all available OpenNebula projects (groups)' }
      list = group_handler.list.map(&:name)
      Rails.logger.debug { "All available projects: #{list.inspect}" }

      list
    end

    def autocreate(credentials, groupname)
      Rails.logger.debug { "Running OpenNebula autocreate for user #{credentials.id.inspect} and group #{groupname.inspect}" }
      group = group_handler.find_by_name(groupname)
      user = user_handler.find_by_name(credentials.id) || register_user(credentials, group)
      add_user_to_group(user, group)
    end

    def token(username, groupname, expiration)
      group = group_handler.find_by_name(groupname)
      token = "#{username}:#{user_handler.token(username, group, expiration)}"
      Rails.logger.debug do
        "Generating OpenNebula token for user #{username.inspect} " \
        "and group #{groupname.inspect} with expiration #{expiration.inspect}: #{token.inspect}"
      end

      token
    end

    private

    def add_user_to_group(user, group)
      Rails.logger.debug { "Adding OpenNebula user #{user.name.inspect} to group #{group.name.inspect}" }
      user_handler.add_group(user, group)
    end

    def register_user(credentials, group)
      Rails.logger.debug { "Registering user #{credentials.id.inspect} in  OpenNebula" }
      user = user_handler.create(credentials.id, Digest::SHA256.hexdigest(credentials.identity), 'remote', group)
      user_handler.update(user, user_template(credentials))

      user
    end

    def user_template(credentials)
      hash = credentials.to_hash
      Rails.logger.debug { "Generating OpenNebula user template from credentials #{hash.inspect}" }
      hash[:authentication] = hash[:authentication][:method]
      hash.delete :groups

      template = hash.map { |key, value| "\"#{key.upcase}\" = \"#{value}\"" }.join("\n")
      Rails.logger.debug { "Template: #{template.inspect}" }

      template
    end
  end
end
