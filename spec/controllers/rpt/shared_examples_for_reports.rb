RSpec.shared_examples "a report" do |format_array|

  # We want to test our views, but for spec performance we
  # only render_views once
  context "with render_views" do
    render_views

    it "is accessible to admins" do
      admin = create :admin
      sign_in admin
      format_array.each do |f|
        get :show, format: f, params: { year: admin.year }
        expect(response).to be_success
      end
    end
  end

  it "is accessible to staff" do
    staff = create :staff
    sign_in staff
    format_array.each do |f|
      get :show, format: f, params: { year: staff.year }
      expect(response).to be_success
    end
  end

  it "is forbidden to users" do
    user = create :user
    sign_in user
    format_array.each do |f|
      get :show, format: f, params: { year: user.year }
      expect(response.code.to_i).to eq(403)
    end
  end

  it "only lets you see your own year" do
    admin = create :admin, :year => 2012
    sign_in admin
    get :show, params: { year: 2011 }
    expect(response.status).to eq(403)
  end

end
