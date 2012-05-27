require "spec_helper"

describe Rpt::AttendeelessUserReportsController do
  it "is accessible to admins" do
    admin = FactoryGirl.create :admin
    sign_in admin
    get :show, :year => admin.year
    response.should be_success
  end

  it "is forbidden to users" do
    user = FactoryGirl.create :user
    sign_in user
    get :show, :year => user.year
    response.code.to_i.should == 403
  end
end
