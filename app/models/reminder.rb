class Reminder < ApplicationRecord
  self.inheritance_column = :_type_disabled

  belongs_to :topic
  validates :type, inclusion: {
    in: %w[once recurring], 
    message: "%{value} is not a valid type"
  }
  validates :remind_at, timestamp_or_cron: true
end