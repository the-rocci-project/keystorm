module Utils
  class RenderableError
    HEADERS_KEY = 'X-Keystorm-Error'.freeze

    attr_accessor :status, :message

    def initialize(status, message = 'Unspecified error')
      @status = status
      @message = message
    end

    def to_json(parameters = nil)
      parameters ||= {}
      { code: parameters[:status], status: status, error: message }.to_json
    end

    def to_headers(parameters = nil)
      parameters ||= {}
      { HEADERS_KEY => to_s(parameters) }
    end

    def to_s(parameters = nil)
      parameters ||= {}
      "[#{parameters[:status]}] #{status}: #{message}"
    end

    alias to_text to_s
    alias to_html to_s
  end
end
