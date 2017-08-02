module Errorable
  extend ActiveSupport::Concern

  included do
    rescue_from Errors::AuthenticationError, with: :handle_authentication_error
    rescue_from Errors::Connectors::ConnectorError, with: :handle_connectors_error
  end

  # Converts a sybolized code and message into a valid Rails reponse.
  # Response is automatically sent via `respond_with` to the client.
  #
  # @param code [Symbol] reponse code (HTTP code as a symbol used in Rails)
  # @param message [String] response message
  def render_error(code, message)
    respond_with Utils::RenderableError.new(code, message), status: code
  end

  # Handles authorization errors and responds with appropriate HTTP code and headers.
  #
  # @param exception [Exception] exception to convert into a response
  def handle_authentication_error
    render_error :unauthorized, 'Not Authorized'
  end

  def handle_connectors_error(ex)
    render_error :not_found, ex.message
  end
end
