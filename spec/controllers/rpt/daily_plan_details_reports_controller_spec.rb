require "spec_helper"

describe Rpt::DailyPlanDetailsReportsController do
  let(:admin) { create :admin }
  before { sign_in admin }

  describe '#new' do
    render_views

    it "succeeds, assigns all daily plans, including disabled" do
      p1 = create :plan, daily: true
      p2 = create :plan, daily: true, disabled: false
      get :new, year: Date.current.year
      response.should be_success
      assigns('daily_plans').should =~ [p1, p2]
    end
  end

  describe '#create' do
    it "delegates to DailyPlanCsvExporter" do
      plan = create :plan, daily: true
      exporter = double("DailyPlanDetailsExporter")
      DailyPlanDetailsExporter.stub(:new) { exporter }
      exporter.should_receive(:to_csv)
      get :create, plan_id: plan.id, year: Date.current.year
      response.should be_success
      expect(response.content_type).to eq('text/csv')
    end
  end
end
