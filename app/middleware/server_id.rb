# frozen_string_literal: true

class ServerId
  SPACE = ' '
  HEADER_KEY = 'Server'
  SERVER_ID = 'Keystorm'
  CHEEKY_HEADERS = {
    'X-Powered-By' => 'Unicorns'
  }.freeze
  SECURITY_HEADERS = {
    'X-Content-Type-Options' => 'nosniff',
    'X-Frame-Options' => 'deny',
    'Content-Security-Policy' => 'default-src \'none\''
  }.freeze
  RACK_ATTACK_THROTTLE_KEY = 'rack.attack.throttle_data'

  def initialize(app)
    @app = app
  end

  def call(env)
    response = @app.call(env)
    response_headers = response[1]

    response_headers[HEADER_KEY] = SERVER_ID
    response_headers.merge! CHEEKY_HEADERS
    response_headers.merge! SECURITY_HEADERS
    response_headers.merge! throttle_headers(env)

    response
  end

  private

  def throttle_headers(env)
    return {} unless env[RACK_ATTACK_THROTTLE_KEY] && env[RACK_ATTACK_THROTTLE_KEY][Rack::Attack::KEYSTORM_THROTTLER_NAME]

    prepare_trottle_headers(env[RACK_ATTACK_THROTTLE_KEY][Rack::Attack::KEYSTORM_THROTTLER_NAME])
  end

  def prepare_trottle_headers(data)
    now = Time.zone.now
    headers = {}
    headers['X-RateLimit-Limit'] = data[:limit]
    headers['X-RateLimit-Remaining'] = data[:limit] - data[:count]
    headers['X-RateLimit-Reset'] = now + (data[:period] - now.to_i % data[:period])

    headers
  end
end
