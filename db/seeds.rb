# Seed the years, bypassing mass assignment security.
Year.create!(
  {
    city:                  'Santa Barbara',
    date_range:            'Jul 30 - Aug 7',
    day_off_date:          Date.new(2011, 8, 3),
    ordinal_number:        27,
    registration_phase:    'complete',
    reply_to_email:        'registrar@gocongress.org',
    start_date:            Date.new(2011, 7, 30),
    state:                 'CA',
    timezone:              'Pacific Time (US & Canada)',
    twitter_url:           nil,
    year:                  2011
  },
  :without_protection => true
)

Year.create!(
  {
    city:                  'Black Mountain',
    date_range:            'August 4 - 12',
    day_off_date:          Date.new(2012, 8, 8),
    ordinal_number:        28,
    registration_phase:    'open',
    reply_to_email:        'arlene@usgocongress12.org',
    start_date:            Date.new(2012, 8, 4),
    state:                 'North Carolina',
    timezone:              'Eastern Time (US & Canada)',
    twitter_url:           'https://twitter.com/#!/GoCongress12',
    year:                  2012
  },
  :without_protection => true
)

Year.create!(
  {
    city:                  'Seattle',
    date_range:            'TBD',
    day_off_date:          Date.new(2013, 8, 8),
    ordinal_number:        29,
    registration_phase:    'closed',
    reply_to_email:        'szimmerman@ctipc.com',
    start_date:            Date.new(2013, 8, 4),
    state:                 'Washington',
    timezone:              'Pacific Time (US & Canada)',
    twitter_url:           'https://twitter.com/#!/GoCongress13',
    year:                  2013
  },
  :without_protection => true
)

Year.create!(
  {
    city:                  'TBD',
    date_range:            'TBD',
    day_off_date:          Date.new(2014, 8, 2),
    ordinal_number:        30,
    registration_phase:    'closed',
    reply_to_email:        'rcristal3@netscape.net',
    start_date:            Date.new(2014, 8, 1),
    state:                 'TBD',
    timezone:              'Eastern Time (US & Canada)',
    year:                  2014
  },
  :without_protection => true
)
