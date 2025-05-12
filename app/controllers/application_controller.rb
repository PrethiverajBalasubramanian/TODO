class ApplicationController < ActionController::API
  include ApiExceptionsHandler
  include ApiResponseHandler
end
