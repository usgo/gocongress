require "rails_helper"

RSpec.describe TransactionsController, :type => :controller do
  let(:transaction_attributes) { { :trantype => "S", :amount => 1, :instrument => "C", :gwdate => Time.utc(Time.now.year, 8, 1), :gwtranid => 1 } }

  it_behaves_like "an admin controller", :transaction do
    let(:user) { create :user }
    let(:extra_params_for_create) { { :transaction => transaction_attributes, :user_email => user.email } }
    let(:updateable_attribute) { :comment }
  end

  context "given a nonexistent email" do
    let(:bad_email) { "nonexistent@example.com" }
    let(:admin) { create :admin }
    let(:user) { create :user }
    before(:each) do
      sign_in admin
    end

    it "will not create the transaction" do
      expect {
        post :create, params: { year: user.year, user_email: bad_email, transaction: transaction_attributes }
      }.to_not change{ Transaction.count }
      expect(response).to render_template :new
    end

    it "will not update the transaction" do
      t = create :tr_sale
      expect { patch_update(t, bad_email) }.to_not change{ t.user.email }
      expect(response).to render_template :edit
    end
  end

  describe "#update" do
    context "as an admin not from the latest year" do
      let(:admin) { create :admin, { year: 2011 } }
      let(:user) { create :user, { year: 2011 } }
      before(:each) do
        sign_in admin
      end

      it "redirects to the correct year" do
        t = create :tr_sale, { user: user, year: 2011 }
        patch_update(t, t.user.email)
        expect(response).to redirect_to transaction_path(id: t.id, year: t.year)
      end
    end
  end

  def patch_update t, email
    patch :update, params: { year: t.year, user_email: email, id: t.id, transaction: transaction_attributes }
  end
end
