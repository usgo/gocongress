require "rails_helper"

RSpec.describe "gotha tournament import", type: :feature do
  let(:password) { 'asdfasdf' }
  let(:admin) { create :admin, :password => password }
  let!(:tournament) { create :tournament, name: "US Open"}
  let!(:round) { create :round, tournament: tournament, number: 1 }
  let!(:ga_attendee_one) { create :ga_attendee_one }  
  let!(:ga_attendee_two) { create :ga_attendee_two }  
  let!(:attendee_three) { create :ga_attendee_two, family_name: "Thomas", given_name: "John", aga_id: "12347"}
  
  context "signed in admin" do
    before do
    visit new_user_session_path(year: admin.year)
    fill_in 'Email', with: admin.email
    fill_in 'Password', with: password
    click_button 'Sign in'
    end

    it "can import round data from Open Gotha xml file" do
      visit round_path(round, year: round.year)
      attach_file("round_import[file]", Rails.root + "spec/fixtures/files/gotha_test_import.xml")
      click_button "Upload"
      expect(page).to have_content 'Imported 1 game appointment'
      expect(page).to have_content 'Imported 1 bye appointment'
    end
    
  end
  
  

end