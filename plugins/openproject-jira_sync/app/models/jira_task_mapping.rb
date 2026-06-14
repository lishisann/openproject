class JiraTaskMapping < ApplicationRecord
  belongs_to :work_package
  validates :jira_issue_key, presence: true, uniqueness: true
end