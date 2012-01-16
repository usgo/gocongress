/* TODO: make this a rake task that takes console input */
u = User.new
u.email														= "bobbacon@earthlink.net"
u.password												= "a1b2c3d4"
u.password_confirmation						= "a1b2c3d4"
u.year														= 2012
u.role														= 'A'
u.build_primary_attendee
u.primary_attendee.given_name 		= "Bob"
u.primary_attendee.family_name 		= "Bacon"
u.primary_attendee.anonymous			= false
u.primary_attendee.gender					= 'm'
u.primary_attendee.aga_id					= 11286
u.primary_attendee.rank						= -6.0
u.primary_attendee.tshirt_size		= '2X'
u.primary_attendee.birth_date			= Date.new(1951,4,26)
u.primary_attendee.year						= 2012
u.primary_attendee.city						= "Hillsborough"
u.primary_attendee.state					= "North Carolina"
u.primary_attendee.zip						= 27278
u.primary_attendee.country				= "US"
u.primary_attendee.address_1			= "2331 Blair Dr"
u.primary_attendee.email					= "bobbacon@earthlink.net"
u.save!
