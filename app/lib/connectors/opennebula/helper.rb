module Connectors
  module Opennebula
    module Helper
      ERRORS = Hash.new(Errors::Connectors::Opennebula::ResourceRetrievalError)
                   .update(::OpenNebula::Error::EAUTHENTICATION => Errors::Connectors::Opennebula::AuthenticationError,
                           ::OpenNebula::Error::EAUTHORIZATION => Errors::Connectors::Opennebula::UserNotAuthorizedError,
                           ::OpenNebula::Error::ENO_EXISTS => Errors::Connectors::Opennebula::ResourceNotFoundError,
                           ::OpenNebula::Error::EACTION => Errors::Connectors::Opennebula::ResourceStateError).freeze

      def handle_opennebula_error
        raise Errors::Connectors::ArgumentError, 'OpenNebula service-wrapper was called without a block!' \
          unless block_given?

        return_value = yield
        return return_value unless OpenNebula.is_error?(return_value)

        raise decode_error(return_value.errno), return_value.message
      end

      def decode_error(errno)
        ERRORS[errno]
      end
    end
  end
end
