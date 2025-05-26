class ReminderMailer < ApplicationMailer
  default from: "prethiveraj.freshworkstest@gmail.com"

  def remind_mail(topic)
    @topic = topic
    puts mail(to: "prethiveraj.balasubramanian@freshworks.com", subject: "Reminder for the topic #{@topic.name}")
  end
end
