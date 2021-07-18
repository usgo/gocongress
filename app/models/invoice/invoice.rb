class Invoice::Invoice
  def initialize(items)
    @items = items
  end

  def total
    subtotals = @items.map { |i| i.price * i.qty }
    subtotals.empty? ? 0 : subtotals.reduce(:+)
  end
end
