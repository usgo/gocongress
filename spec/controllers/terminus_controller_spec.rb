require "rails_helper"

RSpec.describe TerminusController, :type => :controller do
  describe '#show' do
    render_views
    it 'succeeds' do
      u = create :user
      get :show, params: { user_id: u.id, year: u.year }
      expect(response).to be_successful
    end
  end
end
