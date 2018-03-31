require "rails_helper"

RSpec.describe TournamentsController, :type => :controller do
  let(:tnm) { create :tournament }

  describe '#index' do
    render_views

    it 'succeeds' do
      get :index, params: { year: Date.current.year }
      expect(response).to be_successful
    end

    it "assigns only this year's tournaments" do
      t = create(:tournament, :year => Date.current.year)
      x = create(:tournament, :year => 1.year.from_now.year)
      get :index, params: { year: Date.current.year }
      expect(assigns(:tournaments).length).to eq(1)
      expect(assigns(:tournaments)).to eq([t])
    end
  end

  describe "#show" do
    render_views

    it "succeeds" do
      get :show, params: { id: tnm.id, year: tnm.year }
      expect(response).to be_successful
    end
  end

  describe "#update" do
    it "succeeds" do
      sign_in create :admin
      expect {
        patch :update, params: { year: tnm.year, id: tnm.id,
          tournament: { name: '9x9' } }
      }.to change{ tnm.reload.name }.to('9x9')
    end
  end
end
