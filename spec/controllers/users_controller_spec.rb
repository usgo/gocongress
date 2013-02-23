require "spec_helper"

shared_examples "successful get" do |action|
  it "succeeds" do
    get action, year: user.year, id: user.id
    response.should be_success
  end
end

describe UsersController do
  let(:year) { Time.zone.now.year }

  context "as a guest" do
    describe '#index' do
      it 'is forbidden' do
        get :index, :year => year
        response.should be_forbidden
      end
    end
  end

  context "as a user" do
    before do
      sign_in create :user
    end

    describe '#index' do
      it 'is forbidden' do
        get :index, :year => year
        response.should be_forbidden
      end
    end
  end

  context "as staff" do
    before do
      sign_in create :staff
    end

    describe '#index' do
      it 'succeeds' do
        get :index, :year => year
        response.should be_success
      end
    end
  end

  context "as an admin" do
    before do
      sign_in create :admin
    end

    describe '#index' do
      it 'succeeds' do
        get :index, :year => year
        response.should be_success
      end
    end
  end

  describe "#show" do
    let(:user) { create :user, year: 2012 }
    let(:wrong_year) { user.year - 1 }

    def show id, year
      get :show, {id: id, year: year}
      response
    end

    context "as visitor" do
      it "is forbidden" do
        show(user.id, user.year).should be_forbidden
      end
    end

    context "as user" do
      render_views # rendering in a single context is sufficient
      it "the same user succeeds" do
        sign_in user
        show(user.id, user.year).should be_successful
      end
      it "the same user in the wrong year raises RecordNotFound" do
        sign_in user
        expect { show(user.id, wrong_year)
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it "a different user from the same year is forbidden" do
        sign_in create :user, year: user.year
        show(user.id, user.year).should be_forbidden
      end
    end

    context "as staff" do
      it "succeeds" do
        sign_in create :staff, year: user.year
        show(user.id, user.year).should be_successful
      end
      it "from wrong year raises RecordNotFound" do
        sign_in create :staff, year: wrong_year
        expect { show(user.id, wrong_year)
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "as admin" do
      it "succeeds" do
        sign_in create :admin, year: user.year
        show(user.id, user.year).should be_successful
      end
      it "from wrong year raises RecordNotFound" do
        sign_in create :admin, year: wrong_year
        expect { show(user.id, wrong_year)
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '#update' do
    let(:user) { create :user }
    let(:admin) { create :admin }

    it 'user cannot promote themselves' do
      sign_in user
      attrs = accessible_attributes_for(user).merge(role: 'A')
      expect { put :update, :id => user.id, :user => attrs, :year => user.year
        }.to_not change { user.reload.role }
    end

    it 'user can update own email address' do
      sign_in user
      new_email = 'derp' + user.email
      attrs = accessible_attributes_for(user).merge(email: new_email)
      expect { put :update, :id => user.id, :user => attrs, :year => user.year
        }.to change { user.reload.email }
    end

    it 'admin can update user' do
      sign_in admin
      attrs = accessible_attributes_for user
      put :update, :id => user.id, :user => attrs, :year => user.year
      response.should redirect_to user_path user
    end
  end

  context "even when the user has zero attendees" do

    # Nomrally, rspec-rails controller specs do not render views
    # but the following examples were written to reproduce a bug
    # that happened in the views, so we enable rendering.
    render_views

    let(:admin) { create :admin }
    let(:user) { create :user, primary_attendee: nil }

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
