require "spec_helper"

shared_examples "successful get" do |action|
  it "succeeds" do
    get action, year: user.year, id: user.id
    response.should be_success
  end
end

describe UsersController do

  describe "#choose_attendee" do
    let(:user) { FactoryGirl.create :user }
    let(:page) { :events }

    before do
      sign_in user
    end

    def get_choose_attendee user, page
      get :choose_attendee, year: user.year, id: user.id, destination_page: page
    end

    it "is succesful when there are no attendees" do
      get_choose_attendee user, page
      response.should be_success
    end

    it "redirects to the destination page when there is only one attendee" do
      attendee = FactoryGirl.create :attendee, user: user
      get_choose_attendee user, page
      response.should redirect_to edit_attendee_path(attendee, page)
    end

    it "is succesful when there are two or more attendees" do
      1.upto(2) { FactoryGirl.create :attendee, user: user }
      get_choose_attendee user, page
      response.should be_success
    end

    it "is raises an error if given an invalid page" do
      expect { get_choose_attendee user, "foobar" }.to raise_error
    end
  end

  describe "#show" do
    let(:user) { FactoryGirl.create :user, year: 2012 }

    def show id, year
      get :show, {id: id, year: year}
      response
    end

    context "as a visitor" do
      it "is forbidden" do
        show(user.id, user.year).should be_forbidden
      end
    end

    context "as a user" do
      render_views # rendering in a single context is sufficient
      it "the same user succeeds" do
        sign_in user
        show(user.id, user.year).should be_successful
      end
      it "a different user from the same year is forbidden" do
        sign_in FactoryGirl.create :user, year: user.year
        show(user.id, user.year).should be_forbidden
      end
    end

    context "as someone from the same year" do
      it "admin succeeds" do
        sign_in FactoryGirl.create :admin, year: user.year
        show(user.id, user.year).should be_successful
      end
      it "staff succeeds" do
        sign_in FactoryGirl.create :staff, year: user.year
        show(user.id, user.year).should be_successful
      end
    end

    context "as someone from the wrong year" do
      let(:wrong_year) { user.year - 1 }
      it "admin raises RecordNotFound" do
        sign_in FactoryGirl.create :admin, year: wrong_year
        expect { show(user.id, wrong_year)
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it "staff raises RecordNotFound" do
        sign_in FactoryGirl.create :staff, year: wrong_year
        expect { show(user.id, wrong_year)
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "even when the user has zero attendees" do

    # Nomrally, rspec-rails controller specs do not render views
    # but the following examples were written to reproduce a bug
    # that happened in the views, so we enable rendering.
    render_views

    let(:admin) { FactoryGirl.create :admin }
    let(:user) { FactoryGirl.create :user, primary_attendee: nil }

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
