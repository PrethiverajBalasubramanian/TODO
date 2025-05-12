module ApiResponseHandler
  extend ActiveSupport::Concern
  def render_create_response(details)
    render_success_response("CREATED", "The entity created successfully!!!", details)
  end

  def render_update_response(details)
    render_success_response("UPDATED", "The entity saved successfully!!!", details)
  end

  def render_delete_response(details)
    render_success_response("DELETED", "The entity deleted successfully!!!", details)
  end

  def render_success_response(code, message, details = {})
    JsonResponse.new(code, details, message, "success")
  end

  def render_error_response(code, message, details = {})
    JsonResponse.new(code, details, message, "error")
  end

  def render_response_with_root(root, data, status)
    render json: { root => data }, status:
  end

  def render_response(data, status)
    render json: data, status:
  end
end
