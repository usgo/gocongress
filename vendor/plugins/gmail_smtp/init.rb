# In local dev, Gmail SMTP account will be defined in a file for convenience
# Obviously, this file should never be committed to source control
# Thus, at heroku, this file will not be present
# For heroku, use heroku config:add GMAIL_SMTP_USER=username@gmail.com
# -Jared 2010.12.31
if File.file?("#{Rails.root}/vendor/plugins/gmail_smtp/lib/usgc_gmail_account_info.rb") then
	require 'usgc_gmail_account_info'
end

# from the original plugin
require 'smtp_tls'
require 'actionmailer_gmail'
