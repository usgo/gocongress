require "spec_helper"

describe HomeController do
  describe "#index" do
    render_views

    it "succeeds" do
      get :index
      response.should be_success
    end

    it "responds with 406 (Not Acceptable) when format is incorrect" do
      request.env["HTTP_ACCEPT"] = "image/jpeg,image/gif,image/bmp,image/png"
      get :index
      response.response_code.should == 406
    end
  end
end
