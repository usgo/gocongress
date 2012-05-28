shared_examples "a report" do |format_array|

  # We want to test our views, but for spec performance we
  # only render_views once
  context "with render_views" do
    render_views

    it "is accessible to admins" do
      admin = FactoryGirl.create :admin
      sign_in admin
      format_array.each do |f|
        get :show, :format => f, :year => admin.year
        response.should be_success
      end
    end
  end

  it "is accessible to staff" do
    staff = FactoryGirl.create :staff
    sign_in staff
    format_array.each do |f|
      get :show, :format => f, :year => staff.year
      response.should be_success
    end
  end

  it "is forbidden to users" do
    user = FactoryGirl.create :user
    sign_in user
    format_array.each do |f|
      get :show, :format => f, :year => user.year
      response.code.to_i.should == 403
    end
  end

  it "only lets you see your own year" do
    admin = FactoryGirl.create :admin, :year => 2012
    sign_in admin
    get :show, :year => 2011
    response.status.should == 403
  end

end
