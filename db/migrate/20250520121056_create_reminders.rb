class CreateReminders < ActiveRecord::Migration[8.0]
  def change
    create_table :reminders do |t|
      t.text :type
      t.text :remind_at
      t.references :topic, null: false, foreign_key: true
      
      t.timestamps
    end
  end
end
