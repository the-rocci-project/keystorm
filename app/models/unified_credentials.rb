class UnifiedCredentials
  attr_reader :id, :email, :groups, :authentication,
              :name, :identity, :expiration, :issuer,
              :acr

  def initialize(args = {})
    Rails.logger.debug { "Initializing unified credentials: #{args.inspect}" }
    @id = args.fetch(:id)
    @email = args.fetch(:email)
    @groups = args.fetch(:groups)
    @authentication = args.fetch(:authentication)
    @name = args.fetch(:name)
    @identity = args.fetch(:identity)
    @expiration = args.fetch(:expiration)
    @issuer = args.fetch(:issuer, nil)
    @acr = args.fetch(:acr, nil)
  end

  def to_hash
    { id: @id,
      email: @email,
      groups: @groups,
      authentication: @authentication,
      name: @name,
      identity: @identity,
      expiration: @expiration,
      issuer: @issuer,
      acr: @acr }
  end

  delegate :to_s, to: :to_hash
end
