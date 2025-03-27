class CustomPaginator < PagedPaginator
  attr_reader :limit, :offset, :disable_pagination

  def initialize(params)
    @disable_pagination = params.nil?
    super
  end

  def apply(relation, _order_options)
    disable_pagination ? relation : super
  end
end
