require "spec_helper"

describe TerminusController do
  describe '#show' do
    render_views
    it 'succeeds' do
      u = FactoryGirl.create :user
      get :show, :user_id => u.id, :year => u.year
      response.should be_successful
    end
  end
end
