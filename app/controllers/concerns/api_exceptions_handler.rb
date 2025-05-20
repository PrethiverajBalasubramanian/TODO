module ApiExceptionsHandler
  extend ActiveSupport::Concern
  included do
    after_action do |e|
      handle_exceptions(e)
    end
  end

  def handle_exceptions(e)
    if e.is_a?(ActiveRecord::RecordInvalid)
      case e.record.errors.first.type
      when :taken
        duplicate_data(e)
      when :blank
        property_not_found(e)
      when :too_long
        exceed_length(e)
      when :too_short
        subceed_length(e)
      when :invalid
        invalid_data(e)
      end
    elsif e.is_a?(ActiveRecord::RecordNotFound)
      invalid_url_path(e)
    elsif e.is_a?(RootNotFound)
      root_not_found(e)
    else
      internal_server_error(e)
    end
  end

  private
    def property_not_found(e)
      render_error_response(:PROPERTY_NOT_FOUND, e.record.errors.first.full_message, { property: e.record.errors.first.attribute })
    end

    def invalid_url_path(e)
      debugger
      index = request.path.split("/").find_index(e.id) - 1
      render_error_response(:INVALID_URL_PATH, "Invalid Data Given In Url Path.", { url_path_index: index })
    end

    def invalid_data(e)
      render_error_response(:INVALID_DATA, e.record.errors.first.full_message, { property: e.record.errors.first.attribute })
    end

    def duplicate_data(e)
      render_error_response(:DUPLICATE_DATA, e.record.errors.first.full_message, { property: e.record.errors.first.attribute })
    end

    def subceed_length(e)
      error = e.record.errors.first
      render_error_response(:LENGTH_SUBCEEDED, error.full_message, { property: error.attribute, minimum_length:  error.options[:count] })
    end

    def exceed_length(e)
      error = e.record.errors.first
      render_error_response(:LENGTH_EXCEEDED, error.full_message, { property: error.attribute, maximum_length:  error.options[:count] })
    end

    def root_not_found(e)
      render_error_response(:PROPERTY_NOT_FOUND, e.message, { property: e.property })
    end

    def internal_server_error(e)
      render_error_response(:INTERNAL_SERVER_ERROR, "OOPS!!! Something Went Wrong!!!")
    end
end
