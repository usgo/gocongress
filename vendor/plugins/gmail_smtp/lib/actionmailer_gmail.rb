# Warn if GMAIL_SMTP_USER is not defined in the ruby ENV.
# We can't raise an error because "The app’s config vars are not available
# in the environment during the slug compilation process." when Heroku runs
# rake assets:precompile.  
# http://devcenter.heroku.com/articles/rails31_heroku_cedar
if ENV['GMAIL_SMTP_USER'].blank?
	Rails.logger.warn "Warning: GMAIL_SMTP_USER is not defined in the ruby ENV"
end

# Detailed configuration for :smtp delivery method.
# Taken from the original plugin ..
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
	Rails.logger.warn "Warning: SMTP user_name is not defined"
end
