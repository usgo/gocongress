require "rails_helper"

RSpec.shared_examples "successful get" do |action|
  it "succeeds" do
    get action, params: { year: user.year, id: user.id }
    expect(response).to be_success
  end
end

RSpec.describe UsersController, :type => :controller do
  render_views

  let(:user) { create :user }
  let(:user_attributes) { { :email => "test@example.com", :password => "password", :password_confirmation => "password" } }
  let(:wrong_year) { user.year - 1 }
  let(:year) { Time.zone.now.year }

  context "as a visitor" do
    it 'cannot #edit' do
      get :edit, params: { id: user.id, year: user.year }
      expect(response).to be_forbidden
    end

    it 'cannot #index' do
      get :index, params: { year: year }
      expect(response).to be_forbidden
    end

    it "cannot #restore_attendee" do
      a = create :attendee, user_id: user.id, cancelled: true
      patch :restore_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
      expect(response).to be_forbidden
    end

    it 'cannot #show' do
      get :show, params: { id: user.id, year: user.year }
      expect(response).to be_forbidden
    end

    it 'cannot #update' do
      patch :update, params: { id: user.id, user: user.attributes, year: user.year }
      expect(response).to be_forbidden
    end

    it "cannot cancel attendee" do
      a = create :attendee, user_id: user.id
      patch :cancel_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
      expect(response).to be_forbidden
    end
  end

  context "as a user" do
    it 'cannot #destroy self' do
      sign_in user
      expect {
        delete :destroy, params: { id: user.id, year: user.year }
      }.to raise_error(ActionController::UrlGenerationError)
    end

    it 'can #edit_password' do
      sign_in user
      get :edit_password, params: { id: user.id, year: user.year }
      assert_response :success
    end

    describe "#cancel_attendee" do
      it "can cancel attendee" do
        a = create :attendee, user_id: user.id
        p = create :plan
        create :attendee_plan, attendee_id: a.id, plan: p
        sign_in user
        patch :cancel_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
        expect(a.reload.cancelled).to eq(true)
        expect(a.attendee_plans.count).to eq(0)
        expect(response).to redirect_to(user)
      end

      it "cannot cancel attendee of another user" do
        user_two = create :user
        a = create :attendee, user_id: user_two.id
        sign_in user
        patch :cancel_attendee, params: { attendee_id: a.id, id: user_two.id, year: user_two.year }
        expect(response).to be_forbidden
      end
    end

    describe '#edit' do
      it "cannot edit other user" do
        sign_in user
        user_two = create(:user)
        get :edit, params: { id: user_two.id, year: user_two.year }
        expect(response).to be_forbidden
      end

      it "cannot edit themselves" do
        sign_in user
        get :edit, params: { id: user.id, year: user.year }
        expect(response).to be_forbidden
      end
    end

    describe '#index' do
      it 'is forbidden' do
        sign_in user
        get :index, params: { year: year }
        expect(response).to be_forbidden
      end
    end

    describe '#print_cost_summary' do
      it "is forbidden" do
        sign_in user
        get :print_cost_summary, params: { id: user.id, year: user.year }
        expect(response).to be_forbidden
      end
    end

    describe "#restore_attendee" do
      it "can #restore_attendee" do
        a = create :attendee, user_id: user.id, cancelled: true
        sign_in user
        patch :restore_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
        expect(response).to redirect_to edit_registration_path(a, type: 'adult')
      end

      it "cannot #restore_attendee if attendee belongs to another user" do
        user_two = create :user
        a = create :attendee, user_id: user_two.id, cancelled: true
        sign_in user
        patch :restore_attendee, params: { attendee_id: a.id, id: user_two.id, year: user_two.year }
        expect(response).to be_forbidden
      end
    end

    describe '#show' do
      it "the same user succeeds" do
        sign_in user
        get :show, params: { id: user.id, year: user.year }
        expect(response).to be_successful
      end

      it "the same user with an attendee born on February 29 succeeds" do
        create :attendee, user_id: user.id, birth_date: "1996-02-29"
        sign_in user
        get :show, params: { id: user.id, year: user.year }
        expect(response).to be_successful
      end

      it "the same user in the wrong year raises RecordNotFound" do
        sign_in user
        expect {
          get :show, params: { id: user.id, year: wrong_year }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "a different user from the same year is forbidden" do
        sign_in create :user, year: user.year
        get :show, params: { id: user.id, year: user.year }
        expect(response).to be_forbidden
      end
    end

    describe '#update' do
      it 'user cannot promote themselves' do
        sign_in user
        attrs = user_attributes.merge(role: 'A')
        expect {
          patch :update, params: { id: user.id, user: attrs, year: user.year }
        }.to_not change { user.reload.role }
      end

      it 'user can update own email address' do
        sign_in user
        new_email = 'derp' + user.email
        attrs = user_attributes.merge(email: new_email)
        expect {
          patch :update, params: { id: user.id, user: attrs, year: user.year }
        }.to change { user.reload.email }
      end
    end
  end

  context "as staff" do
    let(:staff) { create :staff }

    before do
      sign_in staff
    end

    it "cannot #restore_attendee" do
      a = create :attendee, user_id: user.id, cancelled: true
      patch :restore_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
      expect(response).to be_forbidden
    end

    it "cannot cancel attendee" do
      a = create :attendee, user_id: user.id
      patch :cancel_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
      expect(response).to be_forbidden
    end

    it 'cannot get #new' do
      get :new, params: { year: year }
      expect(response).to be_forbidden
    end

    it 'can #create' do
      expect {
        post :create, params: { user: user_attributes, year: year }
      }.to_not change { User.yr(year).count }
      expect(response).to be_forbidden
    end

    it "can edit email" do
      get :edit_email, params: { id: staff.id, year: staff.year }
      assert_response :success
    end

    describe '#edit' do
      it "cannot edit other user" do
        get :edit, params: { id: user.id, year: user.year }
        expect(response).to be_forbidden
      end

      it "cannot edit themselves" do
        get :edit, params: { id: staff.id, year: staff.year }
        expect(response).to be_forbidden
      end
    end

    describe '#index' do
      it 'succeeds' do
        get :index, params: { year: year }
        expect(response).to be_success
      end
    end

    describe '#show' do
      it "succeeds" do
        sign_in create :staff, year: user.year
        get :show, params: { id: user.id, year: user.year }
        expect(response).to be_successful
      end
      it "from wrong year raises RecordNotFound" do
        sign_in create :staff, year: wrong_year
        expect {
          get :show, params: { id: user.id, year: wrong_year }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "as an admin" do
    before do
      sign_in create :admin
    end

    it "can #restore_attendee" do
      a = create :attendee, user_id: user.id, cancelled: true
      patch :restore_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
      expect(response).to redirect_to edit_registration_path(a, type: 'adult')
    end

    it "can cancel attendee" do
      a = create :attendee, user_id: user.id
      p = create :plan
      create :attendee_plan, plan: p, attendee_id: a.id
      patch :cancel_attendee, params: { attendee_id: a.id, id: user.id, year: user.year }
      expect(a.reload.cancelled).to eq(true)
      expect(a.attendee_plans.count).to eq(0)
      expect(response).to redirect_to(user)
    end

    it 'can get #new' do
      get :new, params: { year: year }
      expect(response).to be_success
    end

    it 'can #create' do
      expect {
        post :create, params: { user: user_attributes, year: year }
      }.to change { User.yr(year).count }.by(+1)
      expect(response).to redirect_to users_path
    end

    describe '#destroy' do
      it 'raises ActionController::UrlGenerationError' do
        user # must `create` before `expect`
        expect {
          delete :destroy, params: { id: user.id, year: user.year }
        }.to raise_error(ActionController::UrlGenerationError)
      end
    end

    it 'can #edit' do
      get :edit, params: { id: user.id, year: user.year }
      assert_response :success
    end

    it 'can #index' do
      user # eager creation
      get :index, params: { year: year }
      expect(response).to be_success
    end

    it 'can #print_cost_summary' do
      sign_in create :admin
      get :print_cost_summary, params: { id: user.id, year: user.year }
      assert_response :success
    end

    describe '#show' do
      it "succeeds" do
        sign_in create :admin, year: user.year
        get :show, params: { id: user.id, year: user.year }
        expect(response).to be_successful
      end
      it "from wrong year raises RecordNotFound" do
        sign_in create :admin, year: wrong_year
        expect {
          get :show, params: { id: user.id, year: wrong_year }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#update' do
      it 'can update any user' do
        patch :update, params: { id: user.id, user: user_attributes, year: user.year }
        expect(response).to redirect_to user_path user
      end

      it "can change a user password" do
        new_pw = 'greeblesnarf'
        expect {
          patch :update, params: { id: user.id,
            user: { password: new_pw },
            year: user.year }
        }.to change { user.reload.encrypted_password }
      end

      it "cannot update user year" do
        u = { 'year' => user.year + 1 }
        expect {
          patch :update, params: { id: user.id, user: user_attributes.merge(u), year: user.year }
        }.to_not change { user.reload.year }
      end
    end
  end

  context "even when the user has zero attendees" do
    let(:admin) { create :admin }
    let(:user) { create :user }

    before(:each) do
      sign_in admin
    end

    # protect against factory changing
    it "the context is correct and it truly has zero attendees" do
      expect(user.attendees).to be_empty
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
