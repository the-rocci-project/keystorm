module Auth
  module Expirable
    def expiration
      (Time.now.to_i + Rails.configuration.keystorm['expiration_window']).to_s
    end
  end
end
