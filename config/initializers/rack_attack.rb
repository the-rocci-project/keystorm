
# Rack attack protection
module Rack
  class Attack
    throttle('req/ip', limit: 120, period: 1.minute, &:ip)

    blocklist('auth-less annoyances') do |req|
      Allow2Ban.filter(req.ip, maxretry: 10, findtime: 1.minute, bantime: 24.hours) do
        req.env[Tokenator::TOKEN_HEADER_KEY].blank?
      end
    end
  end
end

Rails.application.config.middleware.use Rack::Attack if Rails.env.production?
