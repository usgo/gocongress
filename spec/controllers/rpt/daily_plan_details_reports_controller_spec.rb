require "spec_helper"

describe Rpt::DailyPlanDetailsReportsController, :type => :controller do
  let(:admin) { create :admin }
  before { sign_in admin }

  describe '#new' do
    render_views

    it "succeeds, assigns all daily plans, including disabled" do
      p1 = create :plan, daily: true
      p2 = create :plan, daily: true, disabled: false
      get :new, year: Date.current.year
      expect(response).to be_success
      expect(assigns('daily_plans')).to match_array([p1, p2])
    end
  end

  describe '#create' do
    it "delegates to DailyPlanCsvExporter" do
      plan = create :plan, daily: true
      exporter = double("DailyPlanDetailsExporter")
      allow(DailyPlanDetailsExporter).to receive(:new) { exporter }
      expect(exporter).to receive(:to_csv)
      get :create, plan_id: plan.id, year: Date.current.year
      expect(response).to be_success
      expect(response.content_type).to eq('text/csv')
    end
  end
end
