# Offset pagination without extra dependencies.
class Page
  DEFAULT_SIZE = 25
  MAX_SIZE = 100

  attr_reader :number, :size, :total_count

  def initialize(scope, number:, size: DEFAULT_SIZE)
    @scope = scope
    @size = size.to_i.clamp(1, MAX_SIZE)
    count = scope.except(:select, :order).count
    @total_count = count.is_a?(Hash) ? count.size : count
    @number = number.to_i.clamp(1, total_pages)
  end

  def records
    @records ||= @scope.limit(size).offset((number - 1) * size).to_a
  end

  def total_pages
    [ (total_count.to_f / size).ceil, 1 ].max
  end

  def previous_page
    number - 1 if number > 1
  end

  def next_page
    number + 1 if number < total_pages
  end
end
