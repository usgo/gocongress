# this test is a place to design the adapter's interface with
# the rest of the app
require_relative '../../app/services/twilio_text_messenger'

RSpec.describe TwilioTextMessenger do

    let(:message) { 'This is a test message' }
    let(:recipient) { '1231231234'}
    let(:fake_adapter) { instance_double(TwilioTextMessenger) }

    xit 'can send text messages' do
      allow(TwilioTextMessenger).to receive(:new).with(message, recipient).and_return(fake_adapter)
      allow(fake_adapter).to receive(:call).and_return("success")

      expect(fake_adapter).to have_received(:call)
      expect(TwilioTextMessenger).to have_received(:new)
    end
end
