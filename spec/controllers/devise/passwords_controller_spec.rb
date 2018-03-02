require "rails_helper"

RSpec.describe Devise::PasswordsController, :type => :controller do
  let(:year) { Time.zone.now.year }

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    it "succeeds" do
      get :new, params: { year: year }
      expect(response).to be_success
    end
  end

  describe '#create' do
    it "succeeds" do
      post :create, params: { year: year, user: { email: 'lalalalala' } }
      expect(response).to be_success
    end
  end
end
