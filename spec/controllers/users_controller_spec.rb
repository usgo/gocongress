require "spec_helper"

shared_examples "successful get" do |action|
  it "succeeds" do
    get action, year: user.year, id: user.id
    response.should be_success
  end
end

describe UsersController do
  let(:user) { create :user }
  let(:wrong_year) { user.year - 1 }
  let(:year) { Time.zone.now.year }

  context "as a visitor" do
    it 'cannot #edit' do
      get :edit, :id => user.id, :year => user.year
      response.should be_forbidden
    end

    it 'cannot #index' do
      get :index, :year => year
      response.should be_forbidden
    end

    it 'cannot #show' do
      get :show, :id => user.id, :year => user.year
      response.should be_forbidden
    end

    it 'cannot #update' do
      put :update, :id => user.id, :user => user.attributes, :year => user.year
      assert_response 403
    end
  end

  context "as a user" do
    describe '#index' do
      it 'is forbidden' do
        sign_in user
        get :index, :year => year
        response.should be_forbidden
      end
    end

    describe '#print_cost_summary' do
      it "is forbidden" do
        sign_in user
        get :print_cost_summary, :id => user.id, :year => user.year
        response.should be_forbidden
      end
    end

    describe '#show' do
      render_views

      it "the same user succeeds" do
        sign_in user
        get :show, :id => user.id, :year => user.year
        response.should be_successful
      end

      it "the same user in the wrong year raises RecordNotFound" do
        sign_in user
        expect { get :show, :id => user.id, :year => wrong_year
          }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "a different user from the same year is forbidden" do
        sign_in create :user, year: user.year
        get :show, :id => user.id, :year => user.year
        response.should be_forbidden
      end
    end

    describe '#update' do
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

    describe '#show' do
      it "succeeds" do
        sign_in create :staff, year: user.year
        get :show, :id => user.id, :year => user.year
        response.should be_successful
      end
      it "from wrong year raises RecordNotFound" do
        sign_in create :staff, year: wrong_year
        expect { get :show, :id => user.id, :year => wrong_year
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "as an admin" do
    before do
      sign_in create :admin
    end

    it 'can #edit' do
      get :edit, :id => user.id, :year => user.year
      assert_response :success
    end

    it 'can #index' do
      get :index, :year => year
      response.should be_success
    end

    it 'can #print_cost_summary' do
      sign_in create :admin
      get :print_cost_summary, :id => user.id, :year => user.year
      assert_response :success
    end

    describe '#show' do
      it "succeeds" do
        sign_in create :admin, year: user.year
        get :show, :id => user.id, :year => user.year
        response.should be_successful
      end
      it "from wrong year raises RecordNotFound" do
        sign_in create :admin, year: wrong_year
        expect { get :show, :id => user.id, :year => wrong_year
          }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#update' do
      it 'can update any user' do
        attrs = accessible_attributes_for user
        put :update, :id => user.id, :user => attrs, :year => user.year
        response.should redirect_to user_path user
      end

      it "can change a user password" do
        new_pw = 'greeblesnarf'
        expect {
          put :update, :id => user.id,
            :user => { 'password' => new_pw },
            :year => user.year
        }.to change { user.reload.encrypted_password }
      end

      it "cannot update user year" do
        u = { 'year' => user.year + 1 }
        expect { put :update, :id => user.id, :user => u, :year => user.year
          }.to_not change { user.reload.year }
      end
    end
  end

  context "even when the user has zero attendees" do
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
