class TopicsController < ApplicationController
  require_relative "concerns/api_response_handler"
  require_relative "concerns/api_exceptions_handler"
  extend ApiResponseHandler
  extend ApiExceptionsHandler
  before_action :set_topic, only: %i[ show update destroy ]

  # GET /topics
  def index
    @topics = Topic.all
    if @topics.empty?
      render nothing: true, status: 204
    else
      render json: { topics: @topics }
    end
  end

  # GET /topics/1
  def show
    if @topic.nil?
      render nothing: true, status: 204
    else
      render json: { topics: [ @topic ] }
    end
  end

  # POST /topics
  def create
    status = -1

    response = topic_params[:topics].collect { |topic|
      begin
        @topic = Topic.create!(topic)
        status = status == 207 || status == 400 ? 207 : 201
        render_create_response({ id: @topic[:id] })
      rescue => e
        status = status == 207 || status == 201 ? 207 : 400
        handle_exceptions(e)
      end
    }

    render_response_with_root(:topics, response, status)
  end

  # PATCH/PUT /topics/1
  def update
    status = 400
    begin
      topic = topic_params[:topics].first
      begin
        @topic.update(topic)
        response = render_update_response({ id: @topic[:id] })
        status = 200
      rescue => e
        response = handle_exceptions(e)
      end
    rescue => ex
      render_response(handle_exceptions(ex), status)
    end

    render_response_with_root(:topics, response, status)
  end

  # DELETE /topics/1
  def destroy
    @topic.destroy!
  end

  # DELETE /topics
  def destroy_all
    begin
      Topic.all.destroy_all

      render_response_with_root(:topics, [ render_success_response("DELETED", "All topics are deleted", {}) ], 200)
    rescue => e
      handle_exceptions(e)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_topic
      begin
        @topic = Topic.find(params.expect(:id))
      rescue => e
        render_response(handle_exceptions(e), 400)
      end
    end

    # Only allow a list of trusted parameters through.
    def topic_params
      begin
        params.permit(topics: [ :name ]).require(:topics)
      rescue ActionController::ParameterMissing => e
        if e.param.equal?(:topics)
          require_relative "../errors/root_not_found"
          handle_exception(RootNotFound.new(:topics))
        else
          handle_exception(e)
        end
      end
    end
end
