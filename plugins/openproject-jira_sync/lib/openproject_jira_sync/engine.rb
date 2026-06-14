module OpenProjectJiraSync
  class Engine < ::Rails::Engine
    engine_name :openproject_jira_sync

    include OpenProject::Plugins::ActsAsOpEngine

    # ИСПРАВЛЕНИЕ ЗДЕСЬ: используем дефис, чтобы имя совпало с gemspec
    register 'openproject-jira_sync',
             author_url: 'http://localhost',
             requires_openproject: '>= 12.0.0' do
    end

    isolate_namespace OpenProjectJiraSync
  end
end