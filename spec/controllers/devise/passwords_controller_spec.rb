require 'spec_helper'

describe Devise::PasswordsController do
  let(:year) { Time.zone.now.year }

  # Every time you want to unit test a devise controller, you need
  # to tell Devise which mapping to use. http://bit.ly/lhjcUm
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe '#new' do
    it "succeeds" do
      get :new, year: year
      response.should be_success
    end
  end

  describe '#create' do
    it "succeeds" do
      post :create, year: year, user: {email: 'lalalalala'}
      response.should be_success
    end
  end
end
