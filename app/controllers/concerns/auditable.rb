# frozen_string_literal: true

require 'digest'

module Auditable
  extend ActiveSupport::Concern

  def audit_scoped_token
    audit_token(:scoped, digest_token(@cloud_token))
  end

  def audit_unscoped_token
    audit_token(:unscoped, digest_token(headers[x_subject_token_header_key]))
  end

  private

  def audit_token(type, digest)
    Rails.configuration.x.audit.info "#{type.to_s.capitalize} token #{digest} (digest) " \
                                     "from IP #{request.remote_ip} " \
                                     "for credentials #{credentials}"
  end

  def digest_token(token)
    Digest::SHA256.base64digest(token)
  end
end
