class PlanFactReportService
  def self.generate_report(department_id: nil, division_id: nil, start_date:, end_date:)
    query = WorkPackage.where(due_date: start_date..end_date)
    
    query.map do |wp|
      initial_journal = wp.journals.first
      {
        task_id: wp.id,
        subject: wp.subject,
        assignee: wp.assigned_to&.name,
        planned_start: initial_journal.data.start_date,
        planned_due: initial_journal.data.due_date,
        actual_start: wp.start_date,
        actual_due: wp.due_date,
        deviation_days: (wp.due_date && initial_journal.data.due_date) ? (wp.due_date - initial_journal.data.due_date).to_i : 0
      }
    end
  end
end