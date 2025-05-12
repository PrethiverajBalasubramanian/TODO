class JsonResponse
  attr_accessor :code, :details, :message, :status

  def initialize(code, details, message, status)
    @code = code
    @details = details
    @message = message
    @status = status
  end

  def as_json
    { code:, details:, message:, status: }
  end
end

response = JsonResponse.new("SUCCESS", {}, "success", "success")

puts response.as_json
