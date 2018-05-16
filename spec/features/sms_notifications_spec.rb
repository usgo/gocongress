require "rails_helper"

RSpec.feature 'SMS notifications', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }
  let!(:tournament) { create :tournament }
  let!(:round_one) { create :round, tournament: tournament }
  let!(:attendee_one) { create :ga_attendee_one }
  let!(:attendee_two) { create :ga_attendee_two }
  let!(:game_appointment_one) { create :game_appointment, round: round_one, attendee_one: attendee_one, attendee_two: attendee_two }

  before(:each) do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    click_link 'SMS Notifications'
    expect(page).to have_selector 'h2', :text => 'SMS Notifications'
  end
  context 'signed in admin user' do

    it 'can send sms notifications for a round game appointments' do
      click_link "Rounds"
      click_link "Show"
      click_button "Send SMS Notifications"
      expect(page).to have_content '2 notifications sent'
    end

    scenario 'allows a file upload of attendee game pairing data'

    scenario 'matches data from the upload to attendee phone numbers with sms_plans'

    scenario 'allows admin to preview the SMS message to be sent'

    scenario 'allows sms receivers to turn off future sms notifications'
  end
end
