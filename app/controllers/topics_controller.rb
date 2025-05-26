class TopicsController < ApplicationController
  require_relative "concerns/api_response_handler"
  require_relative "concerns/api_exceptions_handler"
  require_relative "concerns/query"
  require_relative "../errors/root_not_found"
  extend ApiResponseHandler
  extend ApiExceptionsHandler
  
  before_action :set_topic, only: %i[ show update destroy ]

  # GET /topics
  def index
    begin
      query = Query.new(Topic)
      if params.key?(:filter)
        require "json"
        filter = JSON.parse(params[:filter], symbolize_names: true)
        query = Query.parse(filter)
      end
      query.set_other_queries(params)

      @topics = query.retrieve

      info = query.get_info
      info[:count] = @topics.count

      if @topics.empty?
        render nothing: true, status: 204
      else
        render json: { topics: @topics, info: info }
      end
    rescue => e
      render_response(handle_exceptions(e), 400)
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
    begin
      topics = topic_params
      response = topics.collect { |topic|
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
    rescue => e
      render_response(handle_exceptions(e), 400)
    end
  end

  # PATCH/PUT /topics/1
  def update
    status = 400
    begin
      topic = topic_params.first
      begin
        @topic.update(topic)
        response = render_update_response({ id: @topic[:id] })
        status = 200
      rescue => e
        response = handle_exceptions(e)
      end
      render_response_with_root(:topics, response, status)
    rescue => ex
      render_response(handle_exceptions(ex), status)
    end
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
      render_response(handle_exceptions(e), 400)
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
        params.permit!.require(:topics)
      rescue ActionController::ParameterMissing => e
        if e.param.equal?(:topics)
          e = RootNotFound.new(:topics)
        end
       raise e
      end
    end
end
