class Attendee::Age

  def initialize birth_date, congress_start_date
    @birth = birth_date || raise(ArgumentError)
    @congress_start = congress_start_date || raise(ArgumentError)
  end

  # `years` returns integer age in years on the
  # start day of congress, not now.
  def years
    year_delta = @congress_start.year - @birth.year
    birthday_after_congress? ? year_delta - 1 : year_delta
  end

  def birthday_after_congress?
    (birthdate_in_congress_year <=> @congress_start) == 1
  end

  def minor?
    @birth + 18.years > @congress_start
  end

  private

  def birthdate_in_congress_year
    if @birth.day == 29 && @birth.month == 2 && @congress_start.leap? == false
      Date.new(@congress_start.year, 3, 1)
    else
      Date.new(@congress_start.year, @birth.month, @birth.day)
    end
  end
end
