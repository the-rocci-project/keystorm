# frozen_string_literal: true

module V3
  module Auth
    class ProjectsController < ApplicationController
      include ProjectsAccessible
      include ProjectsRespondable

      attr_reader :credentials, :cloud

      before_action :prepare_data, :validate_token_header!, :validate_expiration!

      def index
        @cloud = Clouds::CloudProxy.new
        respond_with projects_response
      end

      private

      def prepare_data
        @credentials = UnifiedCredentials.new(Utils::Tokenator.from_token(request.headers[x_auth_token_header_key]))
      end
    end
  end
end
