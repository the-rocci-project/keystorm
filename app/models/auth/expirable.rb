# frozen_string_literal: true

module Auth
  module Expirable
    def expiration
      Time.now.to_i + expiration_window
    end

    def expiration_window
      Rails.configuration.keystorm['expiration_window'].to_i
    end
  end
end
