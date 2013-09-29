module SplitDatetimeParser

  # Given a hash and a prefix, `parse_split_datetime_params`
  # will attempt to find *prefix*_date and *prefix*_time in the
  # hash, combine them, and return an instance of
  # `ActiveSupport::TimeWithZone`.  If an invalid date or time
  # format is found, exceptions are raised.
  def parse_split_datetime hash, prefix
    prefix_for_msg = prefix.to_s.humanize.downcase

    d = hash[:"#{prefix}_date"]
    unless d.blank? || d.match(/\A\d{4}(-\d{2}){2}\z/)
      raise SplitDatetimeParserException,
        "Invalid #{prefix_for_msg} date.  Please use year-month-day format."
    end

    t = hash[:"#{prefix}_time"]
    unless t.blank? || t.match(/\A\d{1,2}:\d{2}[ ][AP]M\z/)
      raise SplitDatetimeParserException,
        "Invalid #{prefix_for_msg} time.  Please use hour:minute AM/PM format."
    end

    if d.blank? ^ t.blank?
      raise SplitDatetimeParserException,
        "Invalid #{prefix_for_msg}.  Specify both date and time or neither."
    end

    # The input matches the strict regexes above, so ask parse()
    # to make a Time instance.  The regexes above don't cover
    # all stupidity (eg. a time like 7:77), so we must rescue
    # from ArgumentError.
    begin
      dt = Time.zone.parse("#{d} #{t}")
    rescue ArgumentError
      raise SplitDatetimeParserException, "invalid date"
    end

    return dt
  end

  class SplitDatetimeParserException < RuntimeError
  end

end
