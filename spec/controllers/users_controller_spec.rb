require "spec_helper"

describe UsersController do
  context "even when the user has zero attendees" do

    # Nomrally, rspec-rails controller specs do not render views
    # but the following examples were written to reproduce a bug
    # that happened in the views, so we enable rendering.
    render_views

    let(:admin) { Factory :admin }
    let(:user) { Factory :user, primary_attendee: nil }

    before(:each) do
      sign_in admin
    end

    # protect against factory changing
    it "the context is correct and it truely has zero attendees" do
      user.attendees.should be_empty
      user.primary_attendee.should be_nil
    end

    describe "GET show" do
      it "succeeds" do
        get :show, year: user.year, id: user.id
        response.should be_success
      end
    end

    describe "GET ledger" do
      it "succeeds" do
        get :ledger, year: user.year, id: user.id
        response.should be_success
      end
    end

    describe "GET invoice" do
      it "succeeds" do
        get :invoice, year: user.year, id: user.id
        response.should be_success
      end
    end

  end
end
