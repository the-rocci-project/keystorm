
# Rack attack protection
module Rack
  class Attack
    KEYSTORM_THROTTLER_NAME = 'req/ip'.freeze

    throttle(KEYSTORM_THROTTLER_NAME, limit: 120, period: 1.minute, &:ip)
  end
end

Rack::Attack.throttled_response = lambda do |env|
  now = Time.zone.now
  match_data = env['rack.attack.match_data']

  headers = {
    'X-RateLimit-Limit' => match_data[:limit],
    'X-RateLimit-Remaining' => 0,
    'X-RateLimit-Reset' => now + (match_data[:period] - now.to_i % match_data[:period])
  }

  [429, headers, ["Throttled\n"]]
end

Rails.application.config.middleware.use Rack::Attack if Rails.env.production?
