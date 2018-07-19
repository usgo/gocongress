require "rails_helper"

RSpec.feature 'SMS notifications', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }
  let!(:tournament) { create :tournament, name: "US Open"}
  let!(:round_one) { create :round, tournament: tournament }
  let!(:attendee_one) { create :ga_attendee_one }
  let!(:attendee_two) { create :ga_attendee_two }
  let!(:attendee_three) { create :ga_attendee_two, given_name: "Underhill"}
  let!(:game_appointment_one) { create :game_appointment, round: round_one, attendee_one: attendee_one, attendee_two: attendee_two }
  let!(:bye_appointment) { create :bye_appointment, round: round_one, attendee: attendee_three } 

  before(:each) do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    click_link 'SMS Notifications'
    expect(page).to have_selector 'h2', :text => 'SMS Notifications'
  end
  context 'signed in admin user' do

    it 'can send sms notifications for a round game and bye appointments', :vcr do
      click_link "Rounds"
      click_link "Show"
      click_button "Send SMS Notifications"
      expect(page).to have_content '2 game notifications sent'
      expect(page).to have_content '1 bye notification sent'
    end
  end
end
