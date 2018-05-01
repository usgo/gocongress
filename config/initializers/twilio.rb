Twilio.configure do |config|
  config.account_sid = ENV['TWILIO_ACCOUNT_SID']
  config.auth_token = ENV['TWILIO_AUTH_TOKEN']
end

# client = Twilio::REST::Client.new
#  client.messages.create({
#    from: ENV['TWILIO_PHONE_NUMBER'],
#    to: '6122035280',
#    body: 'Hello there! This is a test'
#  })
