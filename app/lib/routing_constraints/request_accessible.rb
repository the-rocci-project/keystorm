module RoutingConstraints
  module RequestAccessible
    def parse_request!(request)
      @params = JSON.parse(request.raw_post).deep_symbolize_keys
    rescue JSON::ParserError => ex
      raise Errors::ParsingError, ex
    end

    def methods
      @params.dig(:auth, :identity).fetch(:methods, [])
    end
  end
end
