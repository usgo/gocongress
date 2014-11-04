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
      obf_factor = rand(100)

      allow_any_instance_of(DailyPlanCsvExporter).to receive(:obfuscation_factor) { obf_factor }
      csv = DailyPlanCsvExporter.new(year).render

      ary = CSV.parse csv
      expect(ary.size).to eq(2) # the header, and the one attendee

      expect(ary[0][0]).to eq('user_id')
      expect(ary[0][1]).to eq('attendee_id')
      expect(ary[0][2]).to eq('Family Name')
      expect(ary[0][3]).to eq('Given Name')
      expect(ary[0][4]).to eq('Plan 1') # should be alphabetical
      expect(ary[0][5]).to eq('Plan 2')

      expect(ary[1][0]).to eq((a1.user_id * obf_factor).to_s)
      expect(ary[1][1]).to eq((a1.id * obf_factor).to_s)
      expect(ary[1][2]).to eq(a1.family_name)
      expect(ary[1][3]).to eq(a1.given_name)
      expect(ary[1][4]).to eq(format_date_range(a1ap1d1._date..a1ap1d2._date))
      expect(ary[1][5]).to eq(format_date_range(a1ap2d1._date..a1ap2d1._date))
    end

    def format_date d
      d.strftime '%-m/%-d'
    end

    def format_date_range rng
      "#{format_date(rng.begin)} to #{format_date(rng.end)}"
    end
  end
end
