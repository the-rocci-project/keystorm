module Errorable
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::FormatError, ActionController::UnknownFormat do
      render nothing: true, status: :not_acceptable
    end

    rescue_from Errors::AuthenticationError do
      render_error :unauthorized, 'Not Authorized'
    end

    rescue_from Errors::RequestError do |ex|
      render_error :bad_request, ex.message
    end

    rescue_from Errors::Connectors::ConnectorError do |ex|
      render_error :internal_server_error, ex.message
    end

    rescue_from Errors::Connectors::ServiceError do |ex|
      render_error :service_unavailable, ex.message
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
end
