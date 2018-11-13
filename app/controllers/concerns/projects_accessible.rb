# frozen_string_literal: true

module ProjectsAccessible
  extend ActiveSupport::Concern

  def available_projects
    name = credentials.name
    logger.debug { "Listing available projects for user #{name.inspect}" }
    projects = @cloud.projects & @credentials.groups.map { |group| group[:id] }
    logger.debug { "All projects available for user #{name.inspect}: #{projects.inspect}" }

    projects
  end
end
