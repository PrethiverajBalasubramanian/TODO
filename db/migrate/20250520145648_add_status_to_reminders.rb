class AddStatusToReminders < ActiveRecord::Migration[8.0]
  def change
    add_column :reminders, :status, :text
  end
end
