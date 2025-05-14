class RootNotFound < StandardError
  attr_reader :property

  def initialize(property)
    @property = property

    super(property.to_s + " can't be blank")
  end
end
