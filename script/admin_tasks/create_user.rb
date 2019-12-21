# I use this snippet to create users before registration opens. -Jared 2013
u = User.new
u.email	= "nate.eagle@nationalgocenter.org"
u.password = "foofighters"
u.password_confirmation	= "foofighters"
u.year = 2020
u.role = 'A'
u.save!
