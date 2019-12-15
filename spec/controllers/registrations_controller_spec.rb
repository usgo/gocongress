require "rails_helper"

RSpec.describe RegistrationsController, :type => :controller do
  render_views
  let(:attendee_attributes) {{
    :birth_date => "1981-09-10",
    :country => "US",
    :email => "test@gocongress.org",
    :emergency_name => "Jenny",
    :emergency_phone => "867-5309", 
    :family_name => "Attendee",
    :gender => "m",
    :given_name => "Test",
    :rank => 3,
    :tshirt_size => "NO",
    :will_play_in_us_open => false,
    :receive_sms => false
  }}
  let(:activities) { 1.upto(3).map{ create :activity } }

  context "as a visitor" do
    describe "#create" do
      it "is forbidden for visitors" do
        u = create :user
        attrs = attributes_for :attendee, :user => u
        expect {
          post :create, params: { registration: attrs, user_id: u.id, year: u.year }
        }.to_not change{ Attendee.count }
        expect(response).to be_forbidden
      end
    end

    describe "#edit" do
      it "is forbidden" do
        a = create :attendee
        get :edit, params: { id: a.id, year: a.year }
        expect(response).to be_forbidden
      end
    end

    describe "#new" do
      it "is forbidden" do
        u = create :user
        get :new, params: { user_id: u.id, year: u.year }
        expect(response).to be_forbidden
      end
    end
  end

  context "as a user" do
    let!(:attendee) { create :attendee }
    let(:user) { attendee.user }
    before { sign_in user }

    describe "#create" do
      it "succeeds under own account" do
        a = attendee_attributes.merge(:user_id => user.id)
        expect {
          post :create, params: { registration: a, user_id: user.id, year: user.year }
        }.to change { user.attendees.count }.by(+1)
        expect(response).to redirect_to \
          user_terminus_path(:user_id => user.id, :year => user.year)
      end

      it "fails without any attributes" do
        attrs = {:user_id => user.id}
        expect {
          post :create, params: { registration: attrs, user_id: user.id, year: user.year }
        }.to_not change { Attendee.count }
        expect(response).to render_template :new
        expect(assigns(:registration).errors).not_to be_empty
        expect(assigns(:registration).attendee_number).to eq(2)
      end

      it "renders new view if unsuccessful" do
        stub_registration_to_fail
        post :create, params: { registration: {}, user_id: user.id, year: user.year }
        expect(response).to render_template 'new'
      end

      it "is forbidden to create attendee under a different user" do
        user_two = create :user
        a = attendee_attributes.merge(:user_id => user_two.id)
        expect {
          post :create, params: { registration: a, user_id: user_two.id, year: user_two.year }
        }.not_to change { Attendee.count }
        expect(response).to be_forbidden
      end

      it "accepts m, f, and o for gender" do
        attrs = attendee_attributes.merge(:user_id => user.id)
        attrs[:gender] = "o"
        expect {
          post :create, params: { registration: attrs, user_id: user.id, year: user.year }
        }.to change{ Attendee.count }
        expect(assigns(:registration).errors).to_not include(:gender)
      end

      it "given invalid attributes it does not create attendee" do
        attrs = attendee_attributes.merge(:user_id => user.id)
        attrs[:gender] = "zzzz" # invalid, obviously
        expect {
          post :create, params: { registration: attrs, user_id: user.id, year: user.year }
        }.to_not change{ Attendee.count }
        expect(assigns(:registration).errors).to include(:gender)
      end

      it "minors can specify the name of their guardian" do
        uncle_creepypants = create(:attendee, :birth_date => 50.years.ago)
        attrs = attendee_attributes.merge(:user_id => user.id)
        attrs[:birth_date] = CONGRESS_START_DATE[Time.now.year] - 10.years
        attrs[:guardian_full_name] = "Mommy Moo"
        attrs[:understand_minor] = true
        expect {
          post :create, params: { registration: attrs, user_id: user.id, year: user.year }
        }.to change{ Attendee.count }.by(+1)
      end

      context 'plans' do
        it "saves selected plans" do
          plan = create :plan
          expect {
            post :create, params: { registration: attendee_attributes, plans: { plan.id.to_s => { 'qty' => 1 } }, user_id: user.id, year: user.year }
          }.to change{ plan.attendees.count }.by(+1)
        end

        it "saves selected dates for a daily-rate plan" do
          plan = create :plan, daily: true
          min_date = AttendeePlanDate.minimum(2013)
          dates = (min_date..min_date + 2.days).map{|d| d.strftime('%Y-%m-%d')}
          plan_params = { plan.id.to_s => { 'qty' => 1, 'dates' => dates }}
          expect {
            post :create, params: { registration: attendee_attributes, plans: plan_params, user_id: user.id, year: user.year }
          }.to change{ AttendeePlanDate.count }.by(dates.length)
          expect(plan.attendee_plans.count).to eq(1)
          expect(plan.attendee_plans.first.dates.map(&:_date)).to eq( \
            dates.map{|d| Date.parse(d)}
          )
        end
      end
    end

    describe "#edit" do
      it "cannot edit another user's attendee" do
        a = create :attendee
        get :edit, params: { id: a.id, year: a.year }
        expect(response).to be_forbidden
      end

      it "user can edit their own attendees" do
        get :edit, params: { id: user.attendees.sample.id, year: user.year }
        expect(response).to be_successful
        expect(response).to render_template 'edit'
      end

      it "shows disabled plans, but only if attendee already has them" do
        plan = create :plan, :disabled => true
        attendee.plans << plan
        expect(attendee.get_plan_qty(plan.id)).to eq(1)

        plan2 = create :plan, :disabled => true, \
          :name => "Plan Deux", :plan_category => plan.plan_category

        get :edit, params: { id: attendee.id, year: attendee.year }

        expect(assigns(:registration).plans_by_category).not_to be_nil
        expect(assigns(:registration).plans_by_category).to include(plan.plan_category)
        expect(assigns(:registration).plans_by_category[plan.plan_category]).to eq([plan])
      end
    end

    describe '#new' do
      it 'succeeds' do
        get :new, params: { user_id: user.id, year: user.year }
        expect(response).to be_successful
        expect(assigns(:registration).attendee_number).to eq(2)
      end
    end

    describe "#update" do

      def patch_update attendee_attrs = {}, opts = {}
        patch :update, params: opts.merge(registration: attendee_attrs, id: attendee.id, year: attendee.year)
      end

      it "restores attendee" do
        a = create :attendee, user_id: user.id, cancelled: true
        patch :update, params: { id: a.id, registration: a.attributes, year: a.year }
        expect(a.reload.cancelled).to eq(false)
      end

      it "updates a trivial field" do
        expect {
          patch_update given_name: 'banana'
        }.to change { attendee.reload.given_name }
      end

      it "redirects to terminus if successful" do
        patch_update
        expect(response).to redirect_to \
          user_terminus_path(:user_id => user.id, :year => user.year)
      end

      it "renders edit view if unsuccessful" do
        stub_registration_to_fail
        patch_update
        expect(response).to render_template 'edit'
      end

      it "does not update admin fields" do
        expect {
          patch_update comment: 'banana'
        }.to_not change { attendee.reload.comment }
      end

      it "is forbidden to update another user's attendee" do
        a = create :attendee
        patch :update, params: { id: a.id, registration: a.attributes, year: a.year }
        expect(response).to be_forbidden
      end

      context "activities" do
        it "can add activities to their own attendee" do
          expect { update_activities(attendee, activities) }.to \
            change { attendee.activities.count }.by(activities.length)
        end

        it "cannot add activities to attendee belonging to someone else" do
          attendee2 = create :attendee
          expect { update_activities(attendee2, activities) }.to_not \
            change { attendee2.activities.count }
          expect(response.status).to eq(403)
        end
      end

      context "plans" do
        let(:plan) { create :plan }

        def patch_update plan
          patch :update, params: { year: plan.year, id: attendee.id, plans: { plan.id.to_s => { qty: 1 } } }
        end

        it "updates associated plans" do
          expect { patch_update plan }.to \
            change{ attendee.plans.count }.from(0).to(1)
          expect(attendee.plans).to include(plan)
        end

        it "can clear own attendee plans" do
          attendee.plans << plan
          expect(attendee.plans).to include(plan)
          submit_plans_form attendee, {}
          expect(attendee.reload.plans).to be_empty
        end

        it "can deselect a plan" do
          attendee.plans << plan
          expect(attendee.plans).to include(plan)
          submit_plans_form attendee, params_for_plan(plan, 0)
          expect(attendee.reload.plans).not_to include(plan)
        end

        it "can select a plan for own attendee" do
          expect(attendee.plans).to be_empty
          expect {
            submit_plans_form attendee, params_for_plan(plan, 1)
          }.to change { attendee.plans.count }.by(+1)
          expect(attendee.reload.plans).to include(plan)
        end

        it "cannot select plan for attendee belonging to someone else" do
          a = create :attendee
          expect {
            submit_plans_form a, params_for_plan(plan, 1)
          }.to_not change { a.plans.count }
          expect(response).to be_forbidden
        end

        it "stays on the same page when there is an error" do
          allow_any_instance_of(Registration).to receive(:valid?) { false }
          patch :update, params: { year: attendee.year, id: attendee.id }
          expect(response).to be_successful
          expect(response).to render_template(:edit)
        end

        context "when attendee selects a disabled plan" do
          let(:plan) { create :plan, disabled: true }

          context "and attendee already has that disabled plan" do
            before do
              attendee.plans << plan
            end

            it "should allow attendee to keep the plan" do
              patch_update plan
              expect(attendee.plans).to include(plan)
            end
          end

          context "and attendee does not already have that disabled plan" do
            it "should not allow attendee to select the disabled plan" do
              patch_update plan
              expect(attendee.reload.plans).not_to include(plan)
              expect(response).to be_success
              expect(response).to render_template(:edit)
            end
          end
        end

        context "when attendee deselects a disabled plan" do
          let(:plan) { create :plan, disabled: true, name: "Numero Uno" }
          let(:plan2) { create :plan, name: "Deux", :plan_category => plan.plan_category }
          before do
            attendee.plans << plan
          end

          it "does not allow them to deselect the plan" do
            patch :update, params: { year: attendee.year, id: attendee.id, :"plan_#{plan2.id}_qty" => 1 }
            expect(attendee.reload.plans).to eq([plan])
            expect(response).to be_success
            expect(response).to render_template(:edit)
          end
        end
      end
    end
  end

  context "as an admin" do
    let(:admin) { create :admin }
    before { sign_in admin }

    describe "#create" do
      it "succeeds, creating attendee under any user" do
        u = create :user
        a = attendee_attributes.merge(:user_id => u.id)
        expect {
          post :create, params: { registration: a, year: u.year }
        }.to change { u.attendees.count }.by(+1)
      end
    end

    describe "#destroy" do
      it "raises ActionController::UrlGenerationError" do
        a = create :attendee
        expect {
          delete :destroy, params: { id: a.id, year: a.year }
        }.to raise_error(ActionController::UrlGenerationError)
      end
    end

    describe '#edit' do
      it 'admin can edit any attendee' do
        a = create(:attendee, :year => admin.year)
        get :edit, params: { id: a.id, year: a.year }
        expect(response).to be_successful
      end
    end

    describe '#new' do
      it 'succeeds' do
        get :new, params: { user_id: admin.id, year: admin.year }
        expect(response).to be_successful
      end
    end

    describe '#update' do
      let(:a) { create(:attendee, :year => admin.year) }

      it "can restore attendee" do
        cancelled_attendee = create :attendee, cancelled: true
        patch :update, params: { id: cancelled_attendee.id, registration: cancelled_attendee.attributes, year: cancelled_attendee.year }
        expect(cancelled_attendee.reload.cancelled).to eq(false)
      end

      it 'can update attendee of any user' do
        attrs = attendee_attributes.merge({:family_name => 'banana'})
        expect {
          patch :update, params: { id: a.id, registration: attrs, year: a.year }
        }.to change { a.reload.family_name }
        expect(a.reload.family_name).to eq('banana')
      end

      it "can update admin fields" do
        attrs = attendee_attributes.merge({:comment => 'banana'})
        expect {
          patch :update, params: { id: a.id, registration: attrs, year: a.year }
        }.to change { a.reload.family_name }
        expect(a.reload.comment).to eq('banana')
      end

      it 'can select plan for attendee belonging to someone else' do
        plan = create :plan
        expect(a.plans).to be_empty
        expect {
          submit_plans_form a, params_for_plan(plan, 1)
        }.to change { a.plans.count }.by(+1)
      end

      it "allows an admin to add activities to any attendee" do
        expect { update_activities(a, activities) }.to \
          change { a.activities.count }.by(activities.length)
      end
    end
  end

  def stub_registration_to_fail
    allow_any_instance_of(Registration).to receive(:submit) { false }
  end

  def submit_plans_form(attendee, params)
    params.merge!(:id => attendee.id, :year => attendee.year)
    patch :update, params: params
  end

  def params_for_plan plan, qty
    { 'plans' => { plan.id.to_s => { 'qty' => qty }}}
  end

  def update_activities attendee, activities
    patch :update, params: { id: attendee.id, registration: {}, activity_ids: activities.map(&:id), year: attendee.year }
  end
end
