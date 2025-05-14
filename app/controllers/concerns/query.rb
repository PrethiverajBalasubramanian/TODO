class Query
  extend ActiveSupport::Concern
  require_relative "simple_query"

  @@SORT_ORDER = { ASC: "asc", DESC: "desc" }
  @@OPERATORS = { AND: "and", OR: "or" }

  attr_reader :left, :right, :operator
  attr_accessor :limit, :offset, :sort_by, :sort_order

  def initialize(left: nil, operator: :AND, right: nil)
    @left = left
    @operator = @@OPERATORS.fetch(operator, "and")
    @right = right
  end

  def self.parse(query)
    if query.key?(:group) && query.key?(:operator)
      new(parse(query[:group][0]), query[:operator], parse(query[:group][1]), query.fetch(:attributes, :*))
    else
      new(SimpleQuery.parse(query))
    end
  end

  def apply_other_queries(params)
    @limit = [ 50, params.fetch(:limit, 50).to_i ].min
    page = params.fetch(:page, 1).to_i
    @offset = (page - 1) * limit
    @sort_order = @@SORT_ORDER.fetch(params[:sort_order], :asc)
    @sort_by = params.fetch(:sort_by, :id)
  end

  def build(table)
    query = construct(table)
    "select * from %s%s order by %s %s limit %s offset %s" % [ table, query.blank? ? String.new : " where "+ query, sort_by, sort_order, limit, offset ]
  end

  def get_info
    { page: @offset == 0 ? 1 : (@offset/limit)+1, limit: @limit }
  end

  private
  def construct(table)
    if @left.nil?
      String.new
    elsif !@right.nil?
      "%s %s %s" % [ @left.construct, @operator, @right.construct ]
    else
      @left.construct
    end
  end
end
