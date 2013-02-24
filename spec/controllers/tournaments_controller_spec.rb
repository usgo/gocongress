require "spec_helper"

describe TournamentsController do
  let(:tnm) { create :tournament }

  describe '#index' do
    render_views

    it 'succeeds' do
      get :index, year: Date.current.year
      response.should be_successful
    end

    it "assigns only this year's tournaments" do
      t = create(:tournament, :year => Date.current.year)
      x = create(:tournament, :year => 1.year.from_now.year)
      get :index, :year => Date.current.year
      assigns(:tournaments).length.should == 1
      assigns(:tournaments).should == [t]
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
    it "succeeds" do
      sign_in create :admin
      expect {
        put :update, :year => tnm.year, :id => tnm.id,
          :tournament => {name: '9x9'}
      }.to change{ tnm.reload.name }.to('9x9')
    end
  end
end
