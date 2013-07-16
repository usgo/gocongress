require "spec_helper"
require "controllers/rpt/shared_examples_for_reports"

describe Rpt::DailyPlanReportsController do
  it_behaves_like "a report", %w[html csv]

  describe '#show' do
    let(:admin) { create :admin }
    before { sign_in admin }

    context "html" do
      render_views

      it "succeeds" do
        create :plan, daily: true
        create :plan, daily: true, disabled: false
        get :show, year: Date.current.year
        response.should be_success
        assigns('num_daily_plans').should == 2
      end
    end

    context "csv" do
      it "delegates to DailyPlanCsvExporter" do
        exporter = double("DailyPlanCsvExporter")
        DailyPlanCsvExporter.stub(:new) { exporter }
        exporter.should_receive(:render)
        get :show, format: 'csv', year: Date.current.year
        response.should be_success
      end
    end
  end
end
