require "rails_helper"

RSpec.describe ContactsController, :type => :controller do
  let(:contact) { create :contact }

  describe "#update" do
    it "succeeds" do
      sign_in create :admin
      expect {
        patch :update, :year => contact.year, :id => contact.id,
          :contact => {list_order: 1}
      }.to change{ contact.reload.list_order }.to(1)
    end
  end
end
