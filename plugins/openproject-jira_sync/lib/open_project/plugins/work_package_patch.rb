module OpenProject::Plugins::WorkPackagePatch
  extend ActiveSupport::Concern

  included do
    has_one :jira_mapping, class_name: 'JiraTaskMapping', dependent: :destroy
    has_many :date_change_requests, dependent: :destroy
  end
end