# An admin controller:
#
# 1. forbids staff from creating, updating, or destroying
# 2. allows admins to create, update, or destroy in their own year
# 3. forbids admins from creating, updating, or destroying in other years
#
# The shared_examples take as an argument a symbol containing the
# singular model name, eg. :contact.  It expects that:
#
# 1. a factory of the same name exists
# 2. a path helper exists for the index action, eg. contents_path
#
RSpec.shared_examples "an admin controller" do |model_name|
  let(:resource) { create model_name }
  let(:resource_attrs) { accessible_attributes_for model_name }
  let(:year) { Time.now.year }
  let(:resource_class) { model_name.to_s.classify.constantize }
  let(:index_path) { send (model_name.to_s.pluralize + "_path").to_sym }

  context "as a staffperson" do
    let(:staff) { create :staff }
    before(:each) do
      sign_in staff
    end

    describe "index" do
      render_views
      it "succeeds" do
        get :index, params: { year: year }
        if model_name == :plan_category && year == 2019
          expect(response.status).to eq(302)
        else
          expect(response).to be_successful
        end
      end
    end
    describe "create" do
      it "is forbidden" do
        expect {
          post :create, params: params_for_create(model_name)
        }.to_not change{ resource_class.count }
        expect(response.status).to eq(403)
      end
    end
    describe "edit" do
      it "is forbidden" do
        get :edit, params: { year: resource.year, id: resource.id }
        expect(response.status).to eq(403)
      end
    end
    describe "delete" do
      it "is forbidden" do
        expect(resource).to be_present # create outside expect()
        expect {
          delete :destroy, params: { year: resource.year, id: resource.id }
        }.to_not change{ resource_class.count }
        expect(resource_class.all).to include(resource)
        expect(response.status).to eq(403)
      end
    end
    describe "show" do
      it "succeeds" do
        get :show, params: { year: resource.year, id: resource.id }
        expect(response).to be_success
        expect(assigns(model_name)).to eq(resource)
      end
    end
    describe "update" do
      it "is forbidden" do
        patch :update, params: params_for_update(model_name)
        expect(response.status).to eq(403)
      end
    end
  end

  context "as an admin" do
    let(:admin) { create :admin }
    before(:each) do
      sign_in admin
    end

    describe "index" do
      it "succeeds" do
        get :index, params: { year: year }
        expect(response).to be_successful
      end
    end
    describe "create" do
      it "succeeds" do
        expect {
          post :create, params: params_for_create(model_name)
        }.to change{ resource_class.yr(year).count }.by(+1)

        # not all controllers redirect to the index, some go to the show
        expect(response).to be_redirect
      end
      it "forbids creating in a different year" do
        params = params_for_create(model_name)
        params[:year] = year - 1
        params[model_name].delete :year
        expect { post :create, params: params }.to_not change{ resource_class.count }
        expect(response.status).to eq(403)
      end
    end
    describe "edit" do
      it "succeeds" do
        get :edit, params: { year: resource.year, id: resource.id }
        expect(response).to be_successful
      end
    end
    describe "delete" do
      it "succeeds" do
        expect(resource).to be_present # create outside expect()
        expect {
          delete :destroy, params: { year: resource.year, id: resource.id }
        }.to change{ resource_class.yr(year).count }.by(-1)
        expect(resource_class.all).not_to include(resource)

        # not all controllers redirect to the index after delete
        expect(response).to be_redirect
      end
    end
    describe "show" do
      it "succeeds" do
        get :show, params: { year: resource.year, id: resource.id }
        expect(response).to be_success
        expect(assigns(model_name)).to eq(resource)
      end
    end
    describe "update" do
      it "succeeds" do
        expect {
          patch :update, params: params_for_update(model_name)
          resource.reload
        }.to change { resource.send updateable_attribute }

        # not all controllers redirect to the index, some go to the show
        expect(response).to be_redirect
      end
    end
  end

  def params_for_create model_name
    p = {:year => year}

    # Some controllers require extra params for create, eg.
    # `transaction_controller` takes an extra top-level param
    # `user_email`, and `plan_categories_controller` takes an
    # `event_id` as part of the `plan_category` hash. Recursively
    # merge the extra params using `deep_merge` gem.
    if respond_to? :extra_params_for_create
      p = p.deep_merge extra_params_for_create
    end
  end

  def params_for_update model_name
    p = params_for_create(model_name)
    p[model_name][updateable_attribute] = rand
    p.merge(:id => resource.id)
  end
end
