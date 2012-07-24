require "spec_helper"

describe TournamentsController do
  describe "#update" do
    let(:admin) { FactoryGirl.create :admin }
    let(:tnm) { FactoryGirl.create :tournament }

    it "updates rounds" do
      sign_in admin

      # The params, when adding a new round, look something like:
      tnm_atrs = {
        "rounds_attributes"=>{
          "0"=>{
            "round_start(1i)" => tnm.year,
            "round_start(2i)" => "7",
            "round_start(3i)" => "24",
            "round_start(4i)" => "00",
            "round_start(5i)" => "00"
          }
        }
      }

      expect {
        put :update, :year => tnm.year, :id => tnm.id, :tournament => tnm_atrs
      }.to change{ tnm.rounds.count }.by(+1)
    end
  end
end
