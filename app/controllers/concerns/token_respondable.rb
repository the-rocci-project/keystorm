# frozen_string_literal: true

require 'digest'

module TokenRespondable
  extend ActiveSupport::Concern

  def token_response
    hash = {
      issued_at: timestamp(Time.zone.now),
      methods: methods,
      audit_ids: [],
      expires_at: timestamp(credentials.expiration),
      user: user_hash
    }
    add_aditional_fields! hash

    { token: hash }
  end

  def add_aditional_fields!(hash)
    hash[:is_domain] = domain if respond_to? :domain
    hash[:roles] = roles if respond_to? :roles
    hash[:project] = project if respond_to? :project
    hash[:catalog] = catalog if respond_to? :catalog
  end

  def methods
    credentials.authentication[:method]
  end

  def user_hash
    {
      domain: {
        id: 'Federated',
        name: 'Federated'
      },
      id: Digest::SHA1.hexdigest(credentials.id),
      name: credentials.id,
      'OS-FEDERATION': federation_hash
    }
  end

  def federation_hash
    {
      identity_provider: {
        id: 'egi.eu'
      },
      protocol: {
        id: credentials.authentication[:method]
      },
      groups: credentials.groups.map { |group| { id: group[:id] } }
    }
  end

  def roles_array
    credentials.groups.detect { |group| group[:id] == project_id }[:roles].map { |role| role_hash role }
  end

  def role_hash(role)
    {
      domain_id: nil,
      name: role,
      id: Digest::SHA1.hexdigest(role)
    }
  end

  def project_hash
    {
      domain: {
        id: 'default',
        name: 'Default'
      },
      id: project_id,
      name: project_id
    }
  end

  private :token_response, :add_aditional_fields!, :methods, :user_hash, :federation_hash, :roles_array, :role_hash, :project_hash
end
