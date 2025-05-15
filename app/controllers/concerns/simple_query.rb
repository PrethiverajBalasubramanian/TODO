class SimpleQuery
  extend ActiveSupport::Concern

  COMPARATOR = { EQUALS: "=", NOT_EQUALS: "<>", LIKE: "like", NOT_LIKE: "not like", GREATER_THAN: ">", GREATER_EQUAL: ">=", LESS_THAN: "<", LESS_EQUAL: "<=", BETWEEN: "between", NOT_BETWEEN: "not between" }

  attr_reader :attribute, :comparator, :value

  def initialize(query = {})
    @attribute = query[:attribute]
    @comparator = COMPARATOR[query[:comparator].to_sym]
    @value = query[:value]
  end

  def self.parse(query)
    new(query)
  end

  def construct
    "(%s %s %s)" % [ @attribute, @comparator, format_value(@value) ]
  end

  private
  def format_value(value)
    if value.is_a?(String)
      "'" + value + "'"
    elsif value.is_a?(Array)
      format_value(value[0])+ " AND " + format_value(value[1])
    else
      value.to_s
    end
  end
end
