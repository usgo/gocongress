require "spec_helper"

shared_examples "successful get" do |action|
  it "succeeds" do
    get action, year: user.year, id: user.id
    response.should be_success
  end
end

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
    it "the context is correct and it truly has zero attendees" do
      user.attendees.should be_empty
      user.primary_attendee.should be_nil
    end

    describe "GET show" do
      it_behaves_like "successful get", :show
    end

    describe "GET ledger" do
      it_behaves_like "successful get", :ledger
    end

    describe "GET invoice" do
      it_behaves_like "successful get", :invoice
    end

    describe "GET edit" do
      it_behaves_like "successful get", :edit
    end

    describe "GET edit_email" do
      it_behaves_like "successful get", :edit_email
    end

    describe "GET edit_password" do
      it_behaves_like "successful get", :edit_password
    end

  end
end
