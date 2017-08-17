module ProjectsRespondable
  extend ActiveSupport::Concern

  def projects_response
    {
      links: {
        self: '',
        previous: nil,
        next: nil
      },
      projects: projects_hash
    }
  end

  def projects_hash
    available_projects.map { |project| project_hash project }
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
