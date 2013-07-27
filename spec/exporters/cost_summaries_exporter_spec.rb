require "csv"
require "spec_helper"

describe CostSummariesExporter do

  let(:year) { Date.current.year }
  let(:ex) { CostSummariesExporter.new(year) }
  let(:p1) { create :plan, name: 'Plan A', max_quantity: 10 }
  let(:p2) { create :plan, name: 'Plan B', daily: true }
  let!(:a) { create :attendee, year: year }
  let!(:ap1) { create :attendee_plan, attendee: a, plan: p1, quantity: 3 }
  let!(:ap2) { create :attendee_plan, attendee: a, plan: p2 }
  let(:d) { CONGRESS_START_DATE[Date.current.year] }
  let!(:apd1) { create :attendee_plan_date, attendee_plan: ap2, _date: d }
  let!(:apd2) { create :attendee_plan_date, attendee_plan: ap2, _date: d + 1.day }
  let(:obf_factor) { rand(100) }

  describe "#to_csv" do
    it "returns a csv string with one row per attendee_plan" do
      CostSummariesExporter.any_instance.stub(:obfuscation_factor) { obf_factor }
      ary = CSV.parse ex.to_csv
      expected_user_id = (a.user.id * obf_factor).to_s
      expected_attendee_id = (a.id * obf_factor).to_s
      expected = [
        ['user_id', 'user_email', 'attendee_id', 'given_name', 'family_name', 'plan_name', 'price', 'quantity'],
        [expected_user_id, a.user.email, expected_attendee_id, a.given_name, a.family_name, p1.name, (p1.price.to_f / 100).to_s, ap1.quantity.to_s],
        [expected_user_id, a.user.email, expected_attendee_id, a.given_name, a.family_name, p2.name, (p2.price.to_f / 100).to_s, "2"]
      ]
      expect(ary).to eq(expected)
    end
  end
end
