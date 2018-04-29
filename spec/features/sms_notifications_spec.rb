require "rails_helper"

RSpec.feature 'SMS notifications', :type => :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }

  context 'signed in admin user' do
    before(:each) do
      visit new_user_session_path(year: admin.year)
      fill_in 'Email', with: admin.email
      fill_in 'Password', with: password
      click_button 'Sign in'
      click_link 'SMS Notifications'
      expect(page).to have_selector 'h2', :text => 'SMS Notifications'
    end

    xscenario 'allows an admin to import a batch of attendee game pairings' do
      it 'allows a file upload of attendee game pairing data' do

      end

      it 'matches data from the upload to attendee phone numbers with sms_plans' do

      end
    end

    xscenario 'allows an admin user to send SMS notifications for attendee game batch' do
      it 'allows admin to preview the SMS message to be sent' do

      end

      it 'sends sms messages to attendee with their game info' do

      end

      it 'allows sms receivers to turn off future sms notifications' do

      end
    end

  end

end
