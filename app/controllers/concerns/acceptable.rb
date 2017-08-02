module Acceptable
  extend ActiveSupport::Concern

  # Format constants
  ACCEPTABLE_FORMATS = %i[json].freeze
  ERROR_FORMATS = %i[json html].freeze

  included do
    self.responder = ApplicationResponder
    respond_to(*(ACCEPTABLE_FORMATS | ERROR_FORMATS))
    before_action :validate_requested_format!, :validate_provided_format!
  end

  # Checks request format and defaults or returns HTTP[406].
  def validate_requested_format!
    return if ACCEPTABLE_FORMATS.include?(request.format.symbol)
    render_error :not_acceptable, 'Requested media format is not acceptable'
  end

  # Checks request format and defaults or returns HTTP[406].
  def validate_provided_format!
    return if request.content_mime_type && ACCEPTABLE_FORMATS.include?(request.content_mime_type.symbol)
    render_error :not_acceptable, 'Provided media format is not acceptable'
  end
end
