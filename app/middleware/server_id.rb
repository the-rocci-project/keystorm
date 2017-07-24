class ServerId
  SPACE = ' '.freeze
  HEADER_KEY = 'Server'.freeze
  SERVER_ID = 'Keystorm'.freeze
  CHEEKY_HEADERS = {
    'X-Powered-By' => 'Unicorns'
  }.freeze
  SECURITY_HEADERS = {
    'X-Content-Type-Options' => 'nosniff',
    'X-Frame-Options' => 'deny',
    'Content-Security-Policy' => 'default-src \'none\''
  }.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    response = @app.call(env)
    response_headers = response[1]

    response_headers[HEADER_KEY] = SERVER_ID
    response_headers.merge! CHEEKY_HEADERS
    response_headers.merge! SECURITY_HEADERS

    response
  end
end
