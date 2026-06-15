module OpenProjectJiraSync
  class Engine < ::Rails::Engine
    engine_name :openproject_jira_sync

    include OpenProject::Plugins::ActsAsOpEngine

    register 'openproject-jira_sync',
             author_url: 'http://localhost',
             requires_openproject: '>= 12.0.0' do
    end

    isolate_namespace OpenProjectJiraSync

    config.to_prepare do
      require_dependency 'work_package'

      WorkPackage.class_eval do
        validate :prevent_date_change_for_regular_users

        def prevent_date_change_for_regular_users
          return unless start_date_changed? || due_date_changed?
          
          return if User.current.admin?

          return unless self.project_id

          current_member = Member.find_by(user_id: User.current.id, project_id: self.project_id)
          
          is_manager = current_member&.roles&.any? do |role|
            role.name.include?('Руководитель') || role.name.include?('Manager') || role.name.include?('Project admin')
          end

          unless is_manager
            errors.add(:base, "Изменение сроков заблокировано. Менять даты может только Руководитель. Пожалуйста, используйте статус «Запрос на перенос».")
          end
        end
      end
    end

  end
end