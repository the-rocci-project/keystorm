module ProjectsAccessible
  extend ActiveSupport::Concern

  def available_projects
    @cloud.projects & @credentials.groups.map { |group| group[:id] }
  end
end
