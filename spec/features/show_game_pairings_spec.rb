require "rails_helper"

RSpec.describe "show tournament round pairings" do
  context "Any vistor to the website" do

    let(:tournament) { create :tournament }
    let(:round) { create :round, tournament: tournament }
    let!(:game_one) { create(:game_appointment, round: round) }   
    let!(:game_two) { create(:game_appointment, round: round) }   
    let!(:game_three) { create(:game_appointment, round: round) }   
    it "can navigate to a page showing the games for a tournament" do
      round_link = "Round #{round.number}"
      visit tournament_path(tournament, year: tournament.year)
      click_on(round_link)
      expect(page).to have_selector("#game_appointment_#{game_one.id}", text: "#{game_one.white_player.full_name}") 
      expect(page).to have_selector("#game_appointment_#{game_two.id}", text: "#{game_two.white_player.full_name}") 
      expect(page).to have_selector("#game_appointment_#{game_three.id}", text: "#{game_three.white_player.full_name}") 
    end
    
  end
  
end
