require "spec_helper"

describe DailyPlanCsvExporter do
  describe '#render' do
    it "renders one row per attendee, and one col. per plan" do
      year = Date.current.year
      csd = CONGRESS_START_DATE[year]
      p1 = create :plan, daily: true, name: 'Plan 1'
      p2 = create :plan, daily: true, disabled: false, name: 'Plan 2'
      p3 = create :plan, daily: false
      a1 = create :attendee
      a1ap1 = create :attendee_plan, attendee: a1, plan: p1
      a1ap2 = create :attendee_plan, attendee: a1, plan: p2
      a1ap1d1 = create :attendee_plan_date, attendee_plan: a1ap1, _date: csd
      a1ap1d2 = create :attendee_plan_date, attendee_plan: a1ap1, _date: csd + 3.days
      a1ap2d1 = create :attendee_plan_date, attendee_plan: a1ap2, _date: csd + 1.day

      csv = DailyPlanCsvExporter.new(year).render

      ary = CSV.parse csv
      ary.should have(2).rows # the header, and the one attendee

      ary[0][0].should == 'Family Name'
      ary[0][1].should == 'Given Name'
      ary[0][2].should == 'Plan 1' # should be alphabetical
      ary[0][3].should == 'Plan 2'

      ary[1][0].should == a1.family_name
      ary[1][1].should == a1.given_name
      ary[1][2].should == format_date_range(a1ap1d1._date..a1ap1d2._date)
      ary[1][3].should == format_date_range(a1ap2d1._date..a1ap2d1._date)
    end

    def format_date d
      d.strftime '%-m/%-d'
    end

    def format_date_range rng
      "#{format_date(rng.begin)} to #{format_date(rng.end)}"
    end
  end
end
