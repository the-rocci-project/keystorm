module Acceptable
  extend ActiveSupport::Concern

  # Format constants
  ACCEPTABLE_FORMATS = %i[json].freeze

  included do
    self.responder = ApplicationResponder
    respond_to(*ACCEPTABLE_FORMATS)
    before_action :validate_requested_format!
  end

  # Checks request format and defaults or returns HTTP[406].
  def validate_requested_format!
    return if request.format.respond_to?(:symbol) && ACCEPTABLE_FORMATS.include?(request.format.symbol)
    raise Errors::FormatError, 'Requested media format is not acceptable'
  end

  # Checks request format and defaults or returns HTTP[406].
  def validate_provided_format!
    return if request.content_mime_type.respond_to?(:symbol) && ACCEPTABLE_FORMATS.include?(request.content_mime_type.symbol)
    raise Errors::FormatError, 'Provided media format is not acceptable'
  end
end
