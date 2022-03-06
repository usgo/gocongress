y = Year.new
y.year = 2022
y.city = 'Estes Park'
y.state = 'CO'
y.date_range = 'July 30 - August 7'
y.start_date = Date.new(2022, 7, 30)
y.day_off_date = Date.new(2022, 8, 3)
y.ordinal_number = 38
y.registration_phase = 'closed'
y.reply_to_email = 'webmaster@gocongress.org'
y.timezone = 'Mountain Time (US & Canada)'
y.save!

e = Event.new
e.year = 2022
e.name = 'Congress 2022'
e.save!
