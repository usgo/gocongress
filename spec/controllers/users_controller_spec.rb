require "spec_helper"

shared_examples "successful get" do |action|
  it "succeeds" do
    get action, year: user.year, id: user.id
    response.should be_success
  end
end

describe UsersController do
  render_views

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
      response.should be_forbidden
    end
  end

  context "as a user" do

    it 'cannot #destroy self' do
      sign_in user
      expect { delete :destroy, :id => user.id, :year => user.year
        }.to_not change { User.count }
      response.should be_forbidden
    end

    it 'can #edit_password' do
      sign_in user
      get :edit_password, :id => user.id, :year => user.year
      assert_response :success
    end

    describe '#edit' do
      it "cannot edit other user" do
        sign_in user
        user_two = create(:user)
        get :edit, :id => user_two.id, :year => user_two.year
        response.should be_forbidden
      end

      it "cannot edit themselves" do
        sign_in user
        get :edit, :id => user.id, :year => user.year
        response.should be_forbidden
      end
    end

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
    let(:staff) { create :staff }

    before do
      sign_in staff
    end

    it 'cannot get #new' do
      get :new, :year => year
      response.should be_forbidden
    end

    it 'can #create' do
      expect { post :create, :user => accessible_attributes_for(:user), :year => year
        }.to_not change { User.yr(year).count }
      response.should be_forbidden
    end

    it "can edit email" do
      get :edit_email, :id => staff.id, :year => staff.year
      assert_response :success
    end

    describe '#edit' do
      it "cannot edit other user" do
        get :edit, :id => user.id, :year => user.year
        response.should be_forbidden
      end

      it "cannot edit themselves" do
        get :edit, :id => staff.id, :year => staff.year
        response.should be_forbidden
      end
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

    it 'can get #new' do
      get :new, :year => year
      response.should be_success
    end

    it 'can #create' do
      expect { post :create, :user => accessible_attributes_for(:user), :year => year
        }.to change { User.yr(year).count }.by(+1)
      response.should redirect_to users_path
    end

    it 'can #destroy' do
      user # `create` before `expect` to change
      expect { delete :destroy, :id => user.id, :year => user.year
        }.to change { User.count }.by(-1)

      response.should redirect_to users_path
      flash[:notice].should == 'User deleted'

      # dependent attendees should also be destroyed
      user.id.should be > 0
      Attendee.where(:user_id => user.id).should be_empty
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
