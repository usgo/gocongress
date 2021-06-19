# Create new users for local development
require 'colorize'
u = User.new
u.email	= "admin@localhost.local"
u.password = "foofighters"
u.password_confirmation	= "foofighters"
u.year = 2021
u.confirmed_at = DateTime.now
u.role = 'A'
u.save!
puts "New user created!".green
