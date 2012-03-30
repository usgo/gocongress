module SplitDatetimeParser

  # Given a hash and a prefix, `parse_split_datetime_params`
  # will attempt to find *prefix*_date and *prefix*_time in the
  # hash, combine them, and return an instance of
  # `ActiveSupport::TimeWithZone`.  If an invalid date or time
  # format is found, exceptions are raised.
  def parse_split_datetime hash, prefix
    prefix_for_msg = prefix.to_s.humanize.downcase

    d = hash[:"#{prefix}_date"]
    unless d.blank? || d.match(/^\d{4}(-\d{2}){2}$/)
      raise SplitDatetimeParserException,
        "Invalid #{prefix_for_msg} date.  Please use year-month-day format."
    end

    t = hash[:"#{prefix}_time"]
    unless t.blank? || t.match(/^\d{1,2}:\d{2}[ ][AP]M$/)
      raise SplitDatetimeParserException,
        "Invalid #{prefix_for_msg} time.  Please use hour:minute am/pm format."
    end

    return Time.zone.parse("#{d} #{t}")
  end

  class SplitDatetimeParserException < RuntimeError
  end

end
