module Clouds
  class CloudProxy < SimpleDelegator
    CLOUD_TYPES = {
      opennebula: Clouds::Opennebula
    }.freeze

    def initialize
      super initialize_cloud
    end

    private

    def initialize_cloud
      cloud_type = Rails.configuration.keystorm['cloud'].to_sym
      Rails.logger.debug { "Initializing cloud proxy of type #{cloud_type.inspect}" }
      validate_class! cloud_type
      CLOUD_TYPES[cloud_type].new
    end

    def validate_class!(cloud_type)
      raise Errors::Clouds::LoadError, "Cloud type #{cloud_type} is not supported" unless CLOUD_TYPES.include? cloud_type
    end
  end
end
