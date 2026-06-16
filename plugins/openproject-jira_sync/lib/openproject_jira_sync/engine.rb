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
        validate :prevent_duplicate_jira_id

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

        def prevent_duplicate_jira_id
          cf = CustomField.find_by(name: 'JIRA ID')
          if cf
            cv = self.custom_value_for(cf)
            if cv && cv.value.present?
              is_duplicate = CustomValue.where(custom_field_id: cf.id, value: cv.value, customized_type: 'WorkPackage')
                                        .where.not(customized_id: self.id || 0)
                                        .exists?
              if is_duplicate
                errors.add(:base, "Ошибка интеграции: JIRA ID «#{cv.value}» уже используется в другой задаче. Дубликаты запрещены.")
              end
            end
          end
        end
      end
    end

  end
end