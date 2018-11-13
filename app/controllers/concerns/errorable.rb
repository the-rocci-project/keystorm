# frozen_string_literal: true

module Errorable
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::FormatError, ActionController::UnknownFormat do
      render nothing: true, status: :not_acceptable
    end

    rescue_from Errors::AuthenticationError do |ex|
      log_message! ex, :warn
      render_error :unauthorized, 'Not authorized to access requested content'
    end

    rescue_from Errors::RequestError do |ex|
      log_message! ex
      render_error :bad_request, ex.message
    end

    rescue_from Errors::Connectors::ConnectorError do |ex|
      log_message! ex
      render_error :internal_server_error, 'Underlying cloud platform failed to complete request'
    end

    rescue_from Errors::Connectors::ServiceError do |ex|
      log_message! ex, :fatal
      render_error :service_unavailable, 'Cloud platform is temporarily unavailable'
    end
  end

  # Converts a sybolized code and message into a valid Rails reponse.
  # Response is automatically sent via `respond_with` to the client.
  #
  # @param code [Symbol] reponse code (HTTP code as a symbol used in Rails)
  # @param message [String] response message
  def render_error(code, message)
    respond_with Utils::RenderableError.new(code, message), status: code
  end

  def log_message!(exception, level = :error)
    logger.send(level) { "#{exception.class}: #{exception}" }
  end
end
