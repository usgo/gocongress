require 'rails_helper'

RSpec.describe "API", type: :request do
  context "as javascript" do
    describe "GET AGA Member Search" do
      it "returns a list of members for a text search" do
        get "/api/mm/members/Nathanael", :params => {}
        parsed_body = JSON.parse(response.body)

        expect(parsed_body["success"]).to be true
        expect(parsed_body["payload"]["rows"].length).to be >= 1
      end

      it "returns a specific member for an ID" do
        get "/api/mm/members/18202", :params => {}
        parsed_body = JSON.parse(response.body)

        expect(parsed_body["success"]).to be true
        expect(parsed_body["payload"]["id"]).to eq("18202")
      end
    end

    describe "POST Markdown" do
      it "turns incoming Markdown into HTML" do
        md = "# I love Markdown!\n\nIt's great."
        html = "<h1>I love Markdown!</h1>\n\n<p>It&rsquo;s great.</p>\n"

        post "/api/markdown", :params => { :markdown => md }
        parsed_body = JSON.parse(response.body)

        expect(parsed_body["html"]).to eq(html)
      end
    end

    describe "GET Pandanet Username" do
      it "returns member info for a username that exists" do
        skip 'Test fails with Net::ReadTimeout. Temporarily skip until a solution is found'

        get "/api/pandanet/cloudbrows", :params => {}
        parsed_body = JSON.parse(response.body)

        expect(parsed_body["rating"]).to be_a(String)
        expect(parsed_body["rating"]).not_to be_falsey
      end

      it "returns an error for a username that doesn't exist" do
        skip 'Test fails with Net::ReadTimeout. Temporarily skip until a solution is found'

        get "/api/pandanet/nosanepersonchoosethisname", :params => {}
        parsed_body = JSON.parse(response.body)

        expect(parsed_body["error"]).to eq("not_found")
      end
    end

    describe "GET KGS Username" do
      it "returns a 200 status code for a username that does exist" do
        skip <<-EOS.squish.freeze
          Intermittently failing with "OpenURI::HTTPError: 503". We should
          rewrite this test to avoid actual network operations, by using
          rspec-mocks, or more advanced techniques like webmock or vcr.
        EOS
        get "/api/kgs/cloudbrows", :params => {}

        expect(response).to have_http_status(:ok)
      end

      it "returns a 404 status code for a username that doesn't exist" do
        get "/api/kgs/nosanepersonchoosethisname", :params => {}

        expect(response).to have_http_status(:not_found)
      end
    end
  end

end
