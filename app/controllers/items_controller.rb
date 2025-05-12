class ItemsController < ApplicationController
  require_relative "concerns/api_response_handler"
  require_relative "concerns/api_exceptions_handler"
  extend ApiResponseHandler
  extend ApiExceptionsHandler
  before_action :get_topic
  before_action :set_item, only: %i[ show update destroy ]

  # GET /items
  def index
    debugger
    @items = @topics.items.All
    if @items.empty?
      render nothing: true, status: 204
    else
      render json: { items: @items }
    end
  end

  # GET /items/1
  def show
    if @item.nil?
      render nothing: true, status: 204
    else
      render json: { items: [ @item ] }
    end
  end

  # POST /items
  def create
    status = -1
    @items = item_params[:items]
    response = item_params[:items].collect { |item|
      begin
        @item = @topic.items.build(item)
        status = status == 207 || status == 400 ? 207 : 201
        render_create_response({ id: @item[:id] })
      rescue => e
        status = status == 207 || status == 201 ? 207 : 400
        handle_exceptions(e)
      end
    }

    render_response_with_root(:items, response, status)
  end

  # PATCH/PUT /items/1
  def update
    status = 400
    begin
      item = topic_params[:items].first
      begin
        @item.update(item)
        response = render_update_response({ id: @item[:id] })
        status = 200
      rescue => e
        response = handle_exceptions(e)
      end
    rescue => ex
      render_response(handle_exceptions(ex), status)
    end

    render_response_with_root(:item, response, status)
  end

  # DELETE /items/1
  def destroy
    begin
      @topic.items.all.destroy_all

      render_response_with_root(:topics, [ render_success_response("DELETED", "All items are deleted", {}) ], 200)
    rescue => e
      handle_exceptions(e)
    end
  end

  def mark_all_done
    @items = @topic.items
    @items.each do |item|
      item.done = true
      item.save
    end

    render render_update_response({})
  end

  def mark_all_undone
    @items = @topic.items
    @items.each do |item|
      item.done = false
      item.save
    end

    render render_update_response({})
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = @topic.items.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def item_params
      begin
        params.permit(topics: [ :name ]).require(:topics)
      rescue ActionController::ParameterMissing => e
        if e.param.equal?(:items)
          require_relative "../errors/root_not_found"
          handle_exception(RootNotFound.new(:topics))
        else
          handle_exception(e)
        end
      end
      params.permit(items: [ :description ])
    end

    def get_topic
      @topic = Topic.find(params[:topic_id])
    end
end
