require "spec_helper"

describe HomeController do
  describe "#index" do
    render_views
    it "succeeds" do
      get :index
      response.should be_success
    end
  end
end
