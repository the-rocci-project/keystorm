# frozen_string_literal: true

class ApplicationResponder < ActionController::Responder
  # Redirects resources to the collection path (index action) instead
  # of the resource path (show action) for POST/PUT/DELETE requests.
  # include Responders::CollectionResponder
  def format
    request.format.symbol
  end

  def respond
    display resource
  end
end
