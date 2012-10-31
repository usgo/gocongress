# Application constants
# Changes here require server restart

# CONGRESS_YEAR is the year representing the upcoming congress,
# not necessarily the same as the current calendar year.
CONGRESS_YEAR = 2013

# LATEST_YEAR is usually the same as CONGRESS_YEAR,
# or if we are planning a year ahead but haven't rolled
# it out yet, then LATEST_YEAR may == CONGRESS_YEAR + 1
LATEST_YEAR = 2013

# CONGRESS_START_DATE is the first day of the congress
# For now, keep this a constant so that the attendee model
# can calculate "age on start date".  If I move this to the
# application controller, for example, the model would be
# unable to access it.
CONGRESS_START_DATE = {
  2011 => Date.civil(2011, 7, 30),
  2012 => Date.civil(2012, 8, 4),
  2013 => Date.civil(2013, 8, 3)
}

# DAY_OFF_DATE - The go congress traditionally has one "day off".
# Currently, this only affects the display of this particular day
# on the activity and tournament calendars.
DAY_OFF_DATE = {
  2011 => Date.civil(2011, 8, 3),
  2012 => Date.civil(2012, 8, 8),
  2013 => Date.civil(2013, 8, 7)
}

# PRIORITY_COUNTRIES will appear at the top of the country_select dropdown menu
PRIORITY_COUNTRIES = {
  "United States" => "US",
  "China" => "CN",
  "Japan" => "JP",
  "Korea, Republic of" => "KR"
}

# EMAIL_REGEX used to validate all email addresses
EMAIL_REGEX = /^[a-zA-Z0-9.!#%&*+=?^_{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$/
