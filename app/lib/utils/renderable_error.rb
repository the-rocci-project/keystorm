module Utils
  class RenderableError
    attr_accessor :status, :message

    def initialize(status, message = 'Unspecified error')
      @status = status
      @message = message
    end

    def to_json(parameters = nil)
      parameters ||= {}
      { code: parameters[:status], status: status, error: message }.to_json
    end
  end
end
