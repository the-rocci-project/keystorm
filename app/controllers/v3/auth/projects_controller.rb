module V3
  module Auth
    class ProjectsController < ApplicationController
      before_action :validate_token_header!

      def index
        credentials = UnifiedCredentials.new(Tokenator.from_token(request.headers[token_header_key]))
        credentials_projects = credentials.groups.map { |group| group[:id] }
        cloud_projects = Clouds::CloudProxy.new.projects

        respond_with response_projects(credentials_projects & cloud_projects)
      end

      private

      def response_projects(projects)
        {
          links: {
            self: '',
            previous: nil,
            next: nil
          },
          projects: projects_hash(projects)
        }
      end

      def projects_hash(projects)
        projects.map { |project| project_hash project }
      end

      def project_hash(project)
        {
          is_domain: false,
          description: '',
          links: project_links_hash,
          enabled: true,
          id: project,
          parent_id: '',
          domain_id: '',
          name: project
        }
      end

      def project_links_hash
        { self: '' }
      end
    end
  end
end
