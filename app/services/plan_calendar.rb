class PlanCalendar
  # Given a range of dates, `range_to_matrix` returns a matrix
  # representing a calendar; rows are weeks and cells are days.
  # Cells in the range contain dates, and cells outside the
  # range contain `nil`. -Jared 2013
  def self.range_to_matrix range
    dates_by_week(range).map { |week, dates| padded_week(dates) }
  end

  private

  def self.dates_by_week range
    Set.new(range).classify { |d| d.strftime('%U').to_i }
  end

  # Given an array of dates, `padded_week` returns an array
  # representing a calendric week, Sunday to Saturday, with
  # missing days represented by `nil`. -Jared 2013
  def self.padded_week dates
    0.upto(6).map { |i| dates.find { |d| d.wday == i } }
  end
end
