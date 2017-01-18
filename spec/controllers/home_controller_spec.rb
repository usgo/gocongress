require "rails_helper"

RSpec.describe HomeController, :type => :controller do
  describe "#index" do
    render_views

    it "succeeds" do
      get :index
      expect(response).to be_success
    end

    it "responds with 406 (Not Acceptable) when format is incorrect" do
      request.env["HTTP_ACCEPT"] = "image/jpeg,image/gif,image/bmp,image/png"
      get :index
      expect(response.response_code).to eq(406)
    end
  end
end
