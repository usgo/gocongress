require 'rails_helper'
year = Date.today.year

RSpec.describe "EditableTexts", type: :request do
  context "as a user" do
    let(:user) { create :user }
    before { sign_in user }

    describe "GET editable_texts/" do
      it "is forbidden" do
        get "/#{year}/editable_texts/", :params => {}
        expect(response).to be_forbidden
      end
    end
  end

  context "as staff" do
    let(:staff) { create :staff }
    before { sign_in staff }

    describe "GET editable_texts/" do
      it "is forbidden" do
        get "/#{year}/editable_texts/", :params => {}
        expect(response).to be_forbidden
      end
    end
  end

  context "as an admin" do
    let(:admin) { create :admin }
    before { sign_in admin }

    describe "GET editable_texts/" do
      it "returns http success" do
        get "/#{year}/editable_texts/", :params => {}
        expect(response).to have_http_status(:success)
      end
    end
  end
end
