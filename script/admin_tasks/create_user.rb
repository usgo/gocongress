require 'colorize'
require 'tty-prompt'
prompt = TTY::Prompt.new

# Create a new user for local development

u = User.new
u.email = prompt.ask("New user's email:") do |q|
  q.validate(URI::MailTo::EMAIL_REGEXP, "Invalid email address")
end

u.password = prompt.mask("Create a password:") do |q|
  q.validate(proc { |p| p.length >= 6 })
  q.messages[:valid?] = "Password must be 6 characters or longer"
end

u.password_confirmation = prompt.mask("Confirm password:") do |q|
  q.validate(proc { |p| p == u.password })
  q.messages[:valid?] = "Passwords don't match!"
end

u.year = prompt.ask("Year:", default: DateTime.now.year)

# Pretend we've confirmed the new user's email
u.confirmed_at = DateTime.now

roles = { Admin: 'A', Staff: 'S', User: 'U' }
u.role = prompt.select("User role:", roles)

if u.valid?
  u.save!
  puts "New user created!".cyan
else
  u.errors.each { |k, v| puts "#{k.capitalize}: #{v}".red }
end
