class RemindersController < ApplicationController
  require_relative "concerns/api_response_handler"
  require_relative "concerns/api_exceptions_handler"
  require_relative "../jobs/reminder_job"
  require "active_support/all"
  require "sidekiq/cron/job"
  extend ApiResponseHandler
  extend ApiExceptionsHandler

  before_action :get_topic
  before_action :set_reminder, only: %i[ show destroy pause resume]

  def index
    @reminders = @topic.reminders.all
    if @reminders.empty?
      render nothing: true, status: 204
    else
      render json: { reminders: @reminders }
    end
  end

  def show
   if @reminder.nil?
      render nothing: true, status: 204
   else
      render json: { reminders: [ @reminder ] }
   end
  end

  def create
    status = -1
    response = reminder_params.collect { |reminder|
      begin
        @reminder = @topic.reminders.build(reminder)
        if @reminder.type.eql?("once")
          ist_time = Time.use_zone("Asia/Kolkata") do
            Time.zone.parse(@reminder.remind_at).iso8601
          end
          topic_id = @topic.id
          # @reminder.job_id = ReminderJob.perform_at(ist_time, @topic.id)
          @reminder.job_id = ReminderJob.perform_async(topic_id)
        else
          Sidekiq::Cron::Job.create(
            name:  @topic.id+"#"+@reminder.id,
            cron: @reminder.remind_at,
            class: "ReminderJob"
          )
        end
        @reminder.save!
        status = status == 207 || status == 400 ? 207 : 201
        render_create_response({ id: @reminder.id })
      rescue => e
        status = status == 207 || status == 201 ? 207 : 400
        @reminder.destroy
        handle_exceptions(e)
      end
    }

    render_response_with_root(:reminders, response, status)
  end

  def destroy
    begin
      if @reminder.type.eql?("once")
        Sidekiq::Status.kill(@reminder.job_id)

      else
        Sidekiq::Cron::Job.destroy(@topic.id+"#"+@reminder.id)
      end
      render_response_with_root(:reminders, [ render_delete_response({ id: @reminder[:id] }) ], 200)
    rescue => e
      render_response(handle_exceptions(e), 400)
    end
  end

  def resume
    enable(true, "ENABLED", "The Job enabled successfully!!!")
  end

  def pause
    enable(false, "DISABLED", "The Job disabled successfully!!!")
  end

  def status
    @reminder.status = Sidekiq::Status.status(job_id)
  end


  private
  def set_reminder
    begin
      @reminder = @topic.reminders.find(params.expect(:id))
    rescue => e
      render_response(handle_exceptions(e), 400)
    end
  end

  def reminder_params
    begin
      params.permit(reminders: [ :type, :remind_at ]).require(:reminders)
    rescue ActionController::ParameterMissing => e
      if e.param.eql?(:reminders)
        e = RootNotFound.new(:reminders)
      end
      raise e
    end
  end

    def get_topic
      begin
        @topic = Topic.find(params[:topic_id])
      rescue => e
        render_response(handle_exceptions(e), 400)
      end
    end

    def enable(enable, code, message)
      begin
        cron_job = Sidekiq::Cron::Job.find(@topic.id+"#"+@reminder.id)
        cron_job.enabled = enable
        cron_job.save
        render_response_with_root(:reminders, [ render_success_response(code, { id: @reminder.id }, message) ], 200)
      rescue => e
        render_response(handle_exceptions(e), 400)
      end
    end
end
