require "spec_helper"

describe Rpt::AttendeeReportsController do
  it "is accessible to admins" do
    admin = FactoryGirl.create :admin
    sign_in admin
    %w[html csv].each do |f|
      get :show, :format => f, :year => admin.year
      response.should be_success
    end
  end

  it "is accessible to staff" do
    staff = FactoryGirl.create :staff
    sign_in staff
    %w[html csv].each do |f|
      get :show, :format => 'csv', :year => staff.year
      response.should be_success
    end
  end

  it "is forbidden to users" do
    user = FactoryGirl.create :user
    sign_in user
    %w[html csv].each do |f|
      get :show, :format => f, :year => user.year
      response.code.to_i.should == 403
    end
  end
end
