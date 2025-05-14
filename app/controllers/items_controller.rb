class ItemsController < ApplicationController
  require_relative "concerns/api_response_handler"
  require_relative "concerns/api_exceptions_handler"
  extend ApiResponseHandler
  extend ApiExceptionsHandler
  before_action :get_topic
  before_action :set_item, only: %i[ show update destroy ]

  # GET /items
  def index
    @items = @topic.items.all
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
    response = item_params.collect { |item|
      begin
        @item = @topic.items.build(item)
        @item.save!
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
      debugger
      item = item_params.first
      begin
        @item.update(item)
        response = render_update_response({ id: @item[:id] })
        status = 200
      rescue => e
        response = handle_exceptions(e)
      end
      render_response_with_root(:item, response, status)
    rescue => ex
      render_response(handle_exceptions(ex), status)
    end
  end

  # DELETE /items/1
  def destroy
    begin
      @item.destroy
      render_response_with_root(:items, [ render_delete_response({ id: @item[:id] }) ], 200)
    rescue => e
      render_response(handle_exceptions(e), 400)
    end
  end

  def mark_all_done
    @items = @topic.items
    @items.each do |item|
      item.done = true
      item.save
    end

    render_response_with_root(:items, render_update_response({}), 200)
  end

  def mark_all_undone
    @items = @topic.items
    @items.each do |item|
      item.done = false
      item.save
    end

    render_response_with_root(:items, render_update_response({}), 200)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      begin
        @item = @topic.items.find(params.expect(:id))
      rescue => e
        render_response(handle_exceptions(e), 400)
      end
    end

    # Only allow a list of trusted parameters through.
    def item_params
      begin
        params.permit!.require(:items)
      rescue ActionController::ParameterMissing => e
        if e.param.equal?(:items)
          e = RootNotFound.new(:items)
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
end
