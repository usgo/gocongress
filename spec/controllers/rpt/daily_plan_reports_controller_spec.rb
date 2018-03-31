require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::DailyPlanReportsController, :type => :controller do
  it_behaves_like "a report", %w[html csv]

  describe '#show' do
    let(:admin) { create :admin }
    before { sign_in admin }

    context "html" do
      render_views

      it "succeeds" do
        create :plan, daily: true
        create :plan, daily: true, disabled: false
        get :show, params: { year: Date.current.year }
        expect(response).to be_success
        expect(assigns('num_daily_plans')).to eq(2)
      end
    end

    context "csv" do
      it "delegates to DailyPlanCsvExporter" do
        exporter = double("DailyPlanCsvExporter")
        allow(DailyPlanCsvExporter).to receive(:new) { exporter }
        expect(exporter).to receive(:render)
        get :show, format: 'csv', params: { year: Date.current.year }
        expect(response).to be_success
      end
    end
  end
end
