module RoutingConstraints
  class GarbageConstraint
    def initialize(search_words = [])
      @search_words = search_words
    end

    def matches?(request)
      !@search_words.reduce(false) { |red, elem| red || TokensConstraint.new(elem).matches?(request) }
    end
  end
end
