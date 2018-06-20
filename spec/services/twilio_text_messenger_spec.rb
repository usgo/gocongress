require_relative '../../app/services/twilio_text_messenger'

RSpec.describe TwilioTextMessenger do

    it 'can handle invalid phone-numbers', :vcr do
      message = 'this is a test message'
      recipient = '1231231234'
      adapter = TwilioTextMessenger.new(message, recipient).call
      expect(adapter).to eq("Invalid number")
    end
end
