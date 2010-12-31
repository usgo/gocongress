ActionMailer::Base.smtp_settings = {
	:address => "smtp.gmail.com",
	:port => 587,
	:authentication => :plain,
	:domain => ENV['GMAIL_SMTP_USER'],
	:user_name => ENV['GMAIL_SMTP_USER'],
	:password => ENV['GMAIL_SMTP_PASSWORD'],
}

# Assert that an SMTP user_name is defined -Jared 2010.12.31
if ( ActionMailer::Base.smtp_settings[:user_name].blank? ) then
	raise "Assertion failed: SMTP user_name is not defined"
end
