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
      let(:the_one_true_date_format) { '%Y-%m-%d' }
      render_views

      it "succeeds" do
        csd = CONGRESS_START_DATE[Date.current.year]
        p1 = create :plan, daily: true, name: 'Plan 1'
        p2 = create :plan, daily: true, disabled: false, name: 'Plan 2'
        p3 = create :plan, daily: false
        a1 = create :attendee
        a1ap1 = create :attendee_plan, attendee: a1, plan: p1
        a1ap2 = create :attendee_plan, attendee: a1, plan: p2
        create :attendee_plan_date, attendee_plan: a1ap1, _date: csd
        create :attendee_plan_date, attendee_plan: a1ap2, _date: csd + 1.day

        get :show, format: 'csv', year: Date.current.year
        response.should be_success

        ary = CSV.parse response.body
        ary.should have(2).rows # the header, and the one attendee

        ary[0][0].should == 'Family Name'
        ary[0][1].should == 'Given Name'
        ary[0][2].should == 'Plan 1' # should be alphabetical
        ary[0][3].should == 'Plan 2'

        ary[1][0].should == a1.family_name
        ary[1][1].should == a1.given_name
        ary[1][2].should == csd.strftime(the_one_true_date_format)
        ary[1][3].should == (csd + 1.day).strftime(the_one_true_date_format)
      end
    end
  end
end
