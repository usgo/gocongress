# I use this snippet to create users before registration opens. -Jared 2013
u = User.new
u.email														= "bobbacon@earthlink.net"
u.password												= "a1b2c3d4"
u.password_confirmation						= "a1b2c3d4"
u.year														= 2012
u.role														= 'A'
u.save!
