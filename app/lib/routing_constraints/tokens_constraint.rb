module RoutingConstraints
  class TokensConstraint
    include RequestAccessible

    def initialize(search_word = nil)
      @search_word = search_word
    end

    def matches?(request)
      parse_request! request
      methods.include? @search_word
    rescue Errors::ParsingError
      return false
    end
  end
end
