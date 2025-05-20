class AddJobIdToReminders < ActiveRecord::Migration[8.0]
  def change
    add_column :reminders, :job_id, :text
  end
end
