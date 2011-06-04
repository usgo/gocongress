# Application constants
# Changes here require server restart
CONGRESS_CITY = "Santa Barbara"
CONGRESS_DATE_RANGE = "Jul 30 - Aug 7"
CONGRESS_STATE = "CA"

# Note that CONGRESS_YEAR is not always == Time.now.year
# In 2011, for example, we started working on the 
# website in early Fall 2010
CONGRESS_YEAR = "2011"

# Other
CONGRESS_START_DATE = Time.utc(CONGRESS_YEAR, 7, 30)

# The go congress traditionally has one "day off". Currently, this only affects
# the display of this particular day on the event and tournament calendars.
DAY_OFF_DATE = Date.civil(2011, 8, 3)
