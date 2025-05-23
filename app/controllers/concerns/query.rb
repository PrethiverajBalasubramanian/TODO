class Query
  extend ActiveSupport::Concern
  require_relative "simple_query"

  # before_action :validate_attributes, only: %i[set_attributes]

  @@SORT_ORDER = { ASC: "asc", DESC: "desc" }
  @@OPERATORS = { AND: "and", OR: "or" }

  attr_accessor :limit, :offset, :sort_by, :sort_order, :left, :right, :operator
  attr_reader :resource, :attributes

  def initialize(resource)
    @resource = resource
  end

  def parse(query)
    _query = new
    if query.key?(:group) && query.key?(:operator)
      _query.left = parse(query[:group][0])
      _query.operator = query[:operator]
      _query.right = parse(query[:group][1])
      _query
    else
      _query.left = SimpleQuery.parse(query)
    end
  end

  def set_other_queries(params)
    @limit = [ 50, params.fetch(:limit, 50).to_i ].min
    page = params.fetch(:page, 1).to_i
    @offset = (page - 1) * limit
    @sort_order = @@SORT_ORDER.fetch(params[:sort_order], :asc)
    @sort_by = params.fetch(:sort_by, :id)
    @attributes = params.fetch(:attributes, :*)
  end

  def set_attributes(attributes)
    @attributes = attributes
  end

  # def validate_attributes(attributes)
  #   if !@resource.attributes.include_all?(attributes.split(","))
  #     raise 
  #   end
  # end

  def retrieve
    resource.find_by_sql(build)
  end

  def build
    query = construct
    "select %s from %s%s order by %s %s limit %s offset %s" % [ attributes, resource.table_name, query.blank? ? String.new : " where "+ query, @sort_by, @sort_order, @limit, @offset ]
  end

  def get_info
    { page: @offset == 0 ? 1 : (@offset/limit)+1, limit: @limit, sort_order: @sort_order, sort_by: @sort_by }
  end

  private
  def construct
    if @left.nil?
      String.new
    elsif !@right.nil?
      "%s %s %s" % [ @left.construct, @operator, @right.construct ]
    else
      @left.construct
    end
  end
end
