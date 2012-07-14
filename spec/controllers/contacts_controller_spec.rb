require "spec_helper"

describe ContactsController do
  let(:contact) { FactoryGirl.create :contact }
  let(:contact_attrs) { FactoryGirl.attributes_for :contact }
  let(:year) { Time.now.year }

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
          post :create, year: year, contact: contact_attrs
        }.to_not change{ Contact.count }
        response.status.should == 403
      end
    end
    describe "edit" do
      it "is forbidden" do
        get :edit, year: contact.year, id: contact.id
        response.status.should == 403
      end
    end
    describe "delete" do
      it "is forbidden" do
        contact.should be_present # create outside expect()
        expect {
          delete :destroy, year: contact.year, id: contact.id
        }.to_not change{ Contact.count }
        response.status.should == 403
      end
    end
    describe "update" do
      it "is forbidden" do
        put :update, year: contact.year, id: contact.id, contact: contact_attrs
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
          post :create, year: year, contact: contact_attrs
        }.to change{ Contact.yr(year).count }.by(+1)
        response.should redirect_to(contacts_path)
      end
      it "forbids creating in a different year" do
        different_year = year - 1
        contact_attrs.delete :year
        expect {
          post :create, year: different_year, contact: contact_attrs
        }.to_not change{ Contact.count }
        response.status.should == 403
      end
    end
    describe "edit" do
      it "succeeds" do
        get :edit, year: contact.year, id: contact.id
        response.should be_successful
      end
    end
    describe "delete" do
      it "succeeds" do
        contact.should be_present # create outside expect()
        expect {
          delete :destroy, year: contact.year, id: contact.id
        }.to change{ Contact.yr(year).count }.by(-1)
        response.should redirect_to(contacts_path)
      end
    end
    describe "update" do
      it "succeeds" do
        put :update, year: contact.year, id: contact.id, contact: contact_attrs
        response.should redirect_to(contacts_path)
      end
    end
  end
end
