class TwilioTextMessenger
  attr_reader :message, :recipient

  def initialize(message, recipient)
    @message = message
    @recipient = recipient
  end

  def call
    begin
      client = Twilio::REST::Client.new
      client.messages.create({
        from: ENV['TWILIO_PHONE_NUMBER'],
        to: recipient,
        body: message
      })
    rescue
      return 'Invalid number'
    end

  end
end
