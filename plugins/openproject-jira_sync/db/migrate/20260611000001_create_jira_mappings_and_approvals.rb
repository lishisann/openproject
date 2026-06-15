class CreateJiraMappingsAndApprovals < ActiveRecord::Migration[7.0]
  def change
    create_table :jira_task_mappings do |t|
      t.references :work_package, null: false, foreign_key: true
      t.string :jira_issue_key, null: false
      t.datetime :last_synced_at
      t.timestamps
    end

    add_index :jira_task_mappings, :jira_issue_key, unique: true

    create_table :date_change_requests do |t|
      t.references :work_package, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: { to_table: :users }
      t.references :approver, foreign_key: { to_table: :users }
      
      t.date :old_start_date
      t.date :old_due_date
      t.date :new_start_date
      t.date :new_due_date
      
      t.string :status, default: 'pending'
      t.text :reason
      t.timestamps
    end
  end
end