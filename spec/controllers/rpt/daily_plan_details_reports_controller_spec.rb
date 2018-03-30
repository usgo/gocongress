require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::DailyPlanDetailsReportsController, :type => :controller do
  it_behaves_like "a report", %w[html csv]

  describe '#show' do
    let(:admin) { create :admin }
    before { sign_in admin }

    context "html" do
      render_views

      it "succeeds" do
        get :show, params: { year: Date.current.year }
        expect(response).to be_success
      end
    end

    context "csv" do
      it "delegates to DailyPlanDetailsExporter" do
        exporter = double("DailyPlanDetailsExporter")
        allow(DailyPlanDetailsExporter).to receive(:new) { exporter }
        expect(exporter).to receive(:to_csv)
        get :show, format: 'csv', params: { year: Date.current.year }
        expect(response).to be_success
        expect(response.content_type).to eq('text/csv')
      end
    end
  end
end
