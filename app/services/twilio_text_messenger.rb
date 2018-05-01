class TwilioTextMessenger
  attr_reader :message, :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def call
    client = Twilio::REST::Client.new
    client.messages.create({
      from: ENV['TWILIO_PHONE_NUMBER'],
      to: recipient,
      body: message
    })
  end
end
