# Application constants
# Changes here require server restart

# CONGRESS_YEAR is the year representing the upcoming congress,
# not necessarily the same as the current calendar year.
CONGRESS_YEAR = 2022

# LATEST_YEAR is usually the same as CONGRESS_YEAR,
# or if we are planning a year ahead but haven't rolled
# it out yet, then LATEST_YEAR may == CONGRESS_YEAR + 1
LATEST_YEAR = 2022

# CONGRESS_START_DATE is the first day of the congress
# For now, keep this a constant so that the attendee model
# can calculate "age on start date".  If I move this to the
# application controller, for example, the model would be
# unable to access it.
CONGRESS_START_DATE = {
  2011 => Date.civil(2011, 7, 30),
  2012 => Date.civil(2012, 8, 4),
  2013 => Date.civil(2013, 8, 3),
  2014 => Date.civil(2014, 8, 9),
  2015 => Date.civil(2015, 8, 1),
  2016 => Date.civil(2016, 7, 30),
  2017 => Date.civil(2017, 8, 5),
  2018 => Date.civil(2018, 7, 21),
  2019 => Date.civil(2019, 7, 13),
  2020 => Date.civil(2020, 8, 1),
  2021 => Date.civil(2021, 7, 17),
  2022 => Date.civil(2022, 7, 30)
}

# DAY_OFF_DATE - The go congress traditionally has one "day off".
# Currently, this only affects the display of this particular day
# on the activity and tournament calendars.
DAY_OFF_DATE = {
  2011 => Date.civil(2011, 8, 3),
  2012 => Date.civil(2012, 8, 8),
  2013 => Date.civil(2013, 8, 7),
  2014 => Date.civil(2014, 8, 13),
  2015 => Date.civil(2015, 8, 5),
  2016 => Date.civil(2016, 8, 3),
  2017 => Date.civil(2017, 8, 9),
  2018 => Date.civil(2018, 7, 25),
  2019 => Date.civil(2019, 7, 17),
  2020 => Date.civil(2020, 8, 5),
  2021 => Date.civil(2020, 7, 21),
  2022 => Date.civil(2022, 8, 3)
}

# EMAIL_REGEX used to validate all email addresses, according to
# html5 spec (http://bit.ly/nOR1B6) but slightly stricter (no single
# quotes, backticks, slashes, or dollar signs)
EMAIL_REGEX = /\A[a-zA-Z0-9.!#%&*+=?^_{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*\z/

STATES = [
  ['Alabama', 'AL'],
  ['Alaska', 'AK'],
  ['Arizona', 'AZ'],
  ['Arkansas', 'AR'],
  ['California', 'CA'],
  ['Colorado', 'CO'],
  ['Connecticut', 'CT'],
  ['Delaware', 'DE'],
  ['District of Columbia', 'DC'],
  ['Florida', 'FL'],
  ['Georgia', 'GA'],
  ['Hawaii', 'HI'],
  ['Idaho', 'ID'],
  ['Illinois', 'IL'],
  ['Indiana', 'IN'],
  ['Iowa', 'IA'],
  ['Kansas', 'KS'],
  ['Kentucky', 'KY'],
  ['Louisiana', 'LA'],
  ['Maine', 'ME'],
  ['Maryland', 'MD'],
  ['Massachusetts', 'MA'],
  ['Michigan', 'MI'],
  ['Minnesota', 'MN'],
  ['Mississippi', 'MS'],
  ['Missouri', 'MO'],
  ['Montana', 'MT'],
  ['Nebraska', 'NE'],
  ['Nevada', 'NV'],
  ['New Hampshire', 'NH'],
  ['New Jersey', 'NJ'],
  ['New Mexico', 'NM'],
  ['New York', 'NY'],
  ['North Carolina', 'NC'],
  ['North Dakota', 'ND'],
  ['Ohio', 'OH'],
  ['Oklahoma', 'OK'],
  ['Oregon', 'OR'],
  ['Pennsylvania', 'PA'],
  ['Puerto Rico', 'PR'],
  ['Rhode Island', 'RI'],
  ['South Carolina', 'SC'],
  ['South Dakota', 'SD'],
  ['Tennessee', 'TN'],
  ['Texas', 'TX'],
  ['Utah', 'UT'],
  ['Vermont', 'VT'],
  ['Virginia', 'VA'],
  ['Washington', 'WA'],
  ['West Virginia', 'WV'],
  ['Wisconsin', 'WI'],
  ['Wyoming', 'WY']
].freeze

# Default timeouts for the network connections we open (MM, KGS, etc.) All
# network operations should have specific and thoughtful timeouts. Certain APIs
# will likely have different timeouts, but these are reasonable defaults.
GENERIC_OPEN_TIMEOUT = 3 # seconds
GENERIC_READ_TIMEOUT = 3
