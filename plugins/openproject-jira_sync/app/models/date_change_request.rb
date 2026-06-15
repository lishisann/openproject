class DateChangeRequest < ApplicationRecord
  belongs_to :work_package
  belongs_to :requester, class_name: 'User'
  belongs_to :approver, class_name: 'User', optional: true

  validates :status, inclusion: { in: %w[pending approved rejected] }

  def approve!(user)
    update!(status: 'approved', approver: user)
    work_package.update!(start_date: new_start_date, due_date: new_due_date)
  end

  def reject!(user)
    update!(status: 'rejected', approver: user)
  end
end