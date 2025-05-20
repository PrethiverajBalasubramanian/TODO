class InvalidAttribute
  attr_reader :attribute

  def initialize(attribute)
    @attribute = attribute

    super(attribute.to_s + " is not valid")
  end
end
