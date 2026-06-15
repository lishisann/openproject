class Api::V1::JiraSyncController < ApplicationController
  before_action :require_login

  def fetch
    service = JiraIntegrationService.new(User.current)
    result = service.sync_dates_from_jira(params[:work_package_id], params[:jira_issue_key])
    
    if result[:success]
      render json: result
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  def confirm
    wp = WorkPackage.find(params[:work_package_id])
    JiraTaskMapping.find_or_create_by!(work_package: wp, jira_issue_key: params[:jira_issue_key])
    wp.update!(start_date: params[:start_date], due_date: params[:due_date])
    render json: { message: 'Даты успешно синхронизированы' }, status: :ok
  end
end