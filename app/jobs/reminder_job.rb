require "sidekiq"

class ReminderJob
  include Sidekiq::Worker

  def perform(topic_id)
    debugger
    @topic = Topic.find(topic_id)
    ReminderMailer.remind_mail(@topic).deliver_now
  end
end
