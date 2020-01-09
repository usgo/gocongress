require "rails_helper"

RSpec.describe PaymentsController, :type => :controller do
  render_views

  describe '#new' do
    let(:user) { create :user }
    before { sign_in user }

    it 'creates a Payment Intent with a client secret' do
      get :new, params: { amount: '1.00' }
      expect(assigns[:client_secret]).to_not be_nil
    end
  end

end
