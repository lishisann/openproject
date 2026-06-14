require 'net/http'
require 'json'

class JiraIntegrationService
  def initialize(user)
    @user = user
    @jira_url = ENV['JIRA_BASE_URL']
    @club168871398 (@api_token) = ENV['JIRA_API_TOKEN']
  end

  def sync_dates_from_jira(work_package_id, jira_issue_key)
    work_package = WorkPackage.find(work_package_id)
    
    uri = URI("#{@jira_url}/rest/api/2/issue/#{jira_issue_key}")
    req = Net::HTTP::Get.new(uri)
    req.basic_auth(@user.email, @club168871398 (@api_token))

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      return {
        success: true,
        work_package_id: work_package.id,
        jira_issue_key: jira_issue_key,
        suggested_start_date: data.dig('fields', 'customfield_startdate'),
        suggested_due_date: data.dig('fields', 'duedate')
      }
    else
      return { success: false, error: 'Ошибка подключения к JIRA' }
    end
  end
end