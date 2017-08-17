module V3
  module Auth
    class TokensController < ApplicationController
      include ProjectsAccessible
      include Timestampable
      include TokenRespondable

      before_action :prepare_data, :validate_project!, :prepare_response_data

      def create
        @cloud.autocreate @credentials, @project_id
        cloud_token = @cloud.token @credentials.id, @project_id, @credentials.expiration

        respond cloud_token
      end

      private

      def prepare_data
        parameters = request_parameters.to_h.deep_symbolize_keys
        @cloud = Clouds::CloudProxy.new
        @project_id = parameters.dig(:scope, :project, :id)
        @credentials = UnifiedCredentials.new(Utils::Tokenator.from_token(parameters.dig(:identity, :token, :id)))
      end

      def validate_project!
        raise Errors::RequestError, "No project with name #{@project_id.inspect} found" unless available_projects.include? @project_id
      end

      def prepare_response_data
        @domain = false
        @roles = roles_array
        @project = project_hash
        @catalog = Rails.configuration.keystorm['catalog']
      end

      def respond(cloud_token)
        headers[x_subject_token_header_key] = Utils::Tokenator.to_token(cloud_token)
        respond_with(token_response, status: :created)
      end

      def request_parameters
        params.require(:auth).permit(identity: { methods: [], token: [:id] }, scope: { project: [:id] })
      end

      def methods
        ['token', @credentials.authentication[:method]]
      end
    end
  end
end
