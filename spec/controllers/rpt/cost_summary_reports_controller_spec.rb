require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::CostSummaryReportsController do
  let(:staff) { create :staff }

  it_behaves_like "a report", %w[html csv]

  describe 'html format' do
    it "assigns certain variables" do
      sign_in staff
      get :show, format: 'html', year: staff.year
      expect(assigns(:user_count)).to_not be_nil
      expect(assigns(:attendee_count)).to_not be_nil
    end
  end

  describe 'csv format' do
    it "succeeds, renders csv" do
      sign_in staff
      get :show, format: 'csv', year: staff.year
      expect(response).to be_success
      expect(response.content_type).to eq('text/csv')
    end
  end
end
