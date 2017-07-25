
# Rack attack protection
module Rack
  class Attack
    throttle('req/ip', limit: 120, period: 1.minute, &:ip)
  end
end

Rails.application.config.middleware.use Rack::Attack if Rails.env.production?
