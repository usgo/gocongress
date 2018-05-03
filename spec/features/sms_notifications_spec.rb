require "rails_helper"

RSpec.feature 'SMS notifications', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }

  before(:each) do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    click_link 'SMS Notifications'
    expect(page).to have_selector 'h2', :text => 'SMS Notifications'
  end
  context 'signed in admin user' do



    xscenario 'allows game appointments to be sent out for a specific round using one button' do

    end
    scenario 'allows a file upload of attendee game pairing data'

    scenario 'matches data from the upload to attendee phone numbers with sms_plans'

    scenario 'allows admin to preview the SMS message to be sent'

    scenario 'sends sms messages to attendee with their game info'

    scenario 'allows sms receivers to turn off future sms notifications'
  end
end
