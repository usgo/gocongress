require "spec_helper"

describe TournamentsController do
  let(:tnm) { create :tournament }

  describe '#index' do
    render_views

    it 'succeeds' do
      get :index, year: Date.current.year
      response.should be_successful
    end

    it 'assigns the expected tournaments and rounds' do
      t = create(:tournament, :year => Date.current.year)
      x = create(:tournament, :year => 1.year.from_now.year)

      [t,x].each do |i|
        1.upto(3) do
          i.rounds.create attributes_for(:round)
        end
      end

      get :index, :year => Date.current.year

      # we expect to see only this year's tournament and rounds
      assigns(:tournaments).length.should == 1
      assigns(:rounds_by_date).should be_present
      total_rounds = assigns(:rounds_by_date).values.flatten.length
      total_rounds.should == t.rounds.count
    end
  end

  describe "#show" do
    render_views

    it "succeeds" do
      get :show, id: tnm.id, year: tnm.year
      response.should be_successful
    end
  end

  describe "#update" do
    let(:admin) { create :admin }

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
