require "rails_helper"

RSpec.describe ContactsController, :type => :controller do
  it_behaves_like "an admin controller", :contact do
    let(:extra_params_for_create) { { :contact => { :family_name => "Family Name", :given_name => "Given Name", :list_order => 1, :title => "Title" } } }
    let(:updateable_attribute) { :family_name }
  end

  let(:contact) { create :contact }

  describe "#update" do
    it "succeeds" do
      sign_in create :admin
      expect {
        patch :update, params: { year: contact.year, id: contact.id,
          contact: { list_order: 1 } }
      }.to change{ contact.reload.list_order }.to(1)
    end
  end
end
