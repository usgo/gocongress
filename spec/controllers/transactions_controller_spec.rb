require "spec_helper"

describe TransactionsController do
  describe "#create" do
    it "validates the user email" do
      admin = Factory :admin
      user = Factory :user
      sign_in admin
      expect {
        post :create,
          :year => user.year,
          :user_email => "nonexistent@example.com",
          :transaction => {
            :trantype => "S",
            :instrument => "C",
            :amount => 1055,
            :"gwdate(1i)" => 2012,
            :"gwdate(2i)" => 3,
            :"gwdate(3i)" => 4,
            :gwtranid => 1575926045
          }
      }.to_not change{Transaction.count}
      response.should render_template :new
    end
  end
end
