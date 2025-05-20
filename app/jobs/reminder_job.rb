require 'sidekiq'

class ReminderJob
  include Sidekiq::Worker

  def perform(topic)
    debugger
    puts "Reminder: look at the #{topic.name}"
  end
end