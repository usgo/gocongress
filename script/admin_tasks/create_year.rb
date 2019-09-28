y = Year.new
y.year = 2020
y.city = 'Estes Park'
y.state = 'CO'
y.date_range = 'August 1 - 9'
y.start_date = Date.new(2019, 8, 1)
y.day_off_date = Date.new(2020, 8, 5)
y.ordinal_number = 36
y.registration_phase = 'closed'
y.reply_to_email = 'webmaster@gocongress.org'
y.timezone = 'Mountain Time (US & Canada)'
y.save!

e = Event.new
e.year = 2020
e.name = 'Congress 2020'
e.save!