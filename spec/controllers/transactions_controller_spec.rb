require "spec_helper"

describe TransactionsController do
  it_behaves_like "an admin controller", :transaction do
    let(:user) { FactoryGirl.create :user }
    let(:extra_params_for_create) { {:user_email => user.email} }
  end

  let(:admin) { FactoryGirl.create :admin }
  let(:user) { FactoryGirl.create :user }
  before(:each) do
    sign_in admin
  end

  context "given a nonexistent email" do
    let(:bad_email) { "nonexistent@example.com" }
    it "will not create the transaction" do
      expect {
        post :create,
          :year => user.year,
          :user_email => bad_email,
          :transaction => FactoryGirl.attributes_for(:tr_sale)
      }.to_not change{ Transaction.count }
      response.should render_template :new
    end

    it "will not update the transaction" do
      t = FactoryGirl.create :tr_sale
      expect {
        put :update,
          :year => user.year,
          :user_email => bad_email,
          :id => t.id,
          :transaction => t.attributes
      }.to_not change{ t.user.email }
      response.should render_template :edit
    end
  end
end
