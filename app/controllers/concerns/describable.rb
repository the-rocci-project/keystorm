# frozen_string_literal: true

module Describable
  extend ActiveSupport::Concern

  def api_description
    {
      version: {
        status: 'stable',
        updated: '2017-10-10T00:00:00Z',
        'media-types': media_types,
        id: 'v3.0',
        links: links
      }
    }
  end

  private

  def links
    [
      {
        href: File.join(Rails.configuration.keystorm['endpoint'], 'v3'),
        rel: 'self'
      }
    ]
  end

  def media_types
    [
      {
        base: 'application/json',
        type: 'application/vnd.openstack.identity-v3+json'
      }
    ]
  end
end
