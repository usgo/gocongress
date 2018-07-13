require "rails_helper"

RSpec.describe "show tournament round pairings" do
  context "Any vistor to the website" do
    let(:tournament) { create :tournament }
    let(:round) { create :round, tournament: tournament }
    let(:games) { create_list }   
    fit "can navigate to a page showing the games for a tournament" do
      round_link = "Round #{round.number}"
      visit tournament_path(tournament)
      click_on(round_link)
      expect(page).to have_selector 
    end
    
  end
  
end
