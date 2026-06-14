class Api::V1::DateChangeRequestsController < ApplicationController
  before_action :require_login

  def create
    wp = WorkPackage.find(params[:work_package_id])
    request = DateChangeRequest.create!(
      work_package: wp,
      requester: User.current,
      old_start_date: wp.start_date,
      old_due_date: wp.due_date,
      new_start_date: params[:new_start_date],
      new_due_date: params[:new_due_date],
      reason: params[:reason]
    )
    render json: request, status: :created
  end

  def approve
    request = DateChangeRequest.find(params[:id])
    request.approve!(User.current)
    render json: { message: 'Сроки изменены и согласованы' }
  end
end