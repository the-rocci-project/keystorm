module V3
  module Auth
    class ProjectsController < ApplicationController
      include ProjectsAccessible
      include ProjectsRespondable

      before_action :validate_token_header!

      def index
        @credentials = UnifiedCredentials.new(Utils::Tokenator.from_token(request.headers[x_auth_token_header_key]))
        @cloud = Clouds::CloudProxy.new
        respond_with projects_response
      end
    end
  end
end
