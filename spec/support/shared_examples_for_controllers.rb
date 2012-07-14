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
shared_examples "an admin controller" do |model_name|
  let(:resource) { FactoryGirl.create model_name }
  let(:resource_attrs) { FactoryGirl.attributes_for model_name }
  let(:year) { Time.now.year }
  let(:resource_class) { model_name.to_s.classify.constantize }
  let(:index_path) { send (model_name.pluralize + "_path").to_sym }

  context "as a staffperson" do
    let(:staff) { FactoryGirl.create :staff }
    before(:each) do
      sign_in staff
    end

    describe "index" do
      render_views
      it "succeeds" do
        get :index, year: year
        response.should be_successful
      end
    end
    describe "create" do
      it "is forbidden" do
        expect {
          post :create, :year => year, model_name => resource_attrs
        }.to_not change{ resource_class.count }
        response.status.should == 403
      end
    end
    describe "edit" do
      it "is forbidden" do
        get :edit, year: resource.year, id: resource.id
        response.status.should == 403
      end
    end
    describe "delete" do
      it "is forbidden" do
        resource.should be_present # create outside expect()
        expect {
          delete :destroy, year: resource.year, id: resource.id
        }.to_not change{ resource_class.count }
        response.status.should == 403
      end
    end
    describe "update" do
      it "is forbidden" do
        put :update, :year => resource.year, :id => resource.id, model_name => resource_attrs
        response.status.should == 403
      end
    end
  end

  context "as an admin" do
    let(:admin) { FactoryGirl.create :admin }
    before(:each) do
      sign_in admin
    end

    describe "index" do
      it "succeeds" do
        get :index, year: year
        response.should be_successful
      end
    end
    describe "create" do
      it "succeeds" do
        expect {
          post :create, :year => year, model_name => resource_attrs
        }.to change{ resource_class.yr(year).count }.by(+1)
        response.should redirect_to(contacts_path)
      end
      it "forbids creating in a different year" do
        different_year = year - 1
        resource_attrs.delete :year
        expect {
          post :create, :year => different_year, model_name => resource_attrs
        }.to_not change{ resource_class.count }
        response.status.should == 403
      end
    end
    describe "edit" do
      it "succeeds" do
        get :edit, year: resource.year, id: resource.id
        response.should be_successful
      end
    end
    describe "delete" do
      it "succeeds" do
        resource.should be_present # create outside expect()
        expect {
          delete :destroy, year: resource.year, id: resource.id
        }.to change{ resource_class.yr(year).count }.by(-1)
        response.should redirect_to(contacts_path)
      end
    end
    describe "update" do
      it "succeeds" do
        put :update, :year => resource.year, :id => resource.id, model_name => resource_attrs
        response.should redirect_to(contacts_path)
      end
    end
  end
end
