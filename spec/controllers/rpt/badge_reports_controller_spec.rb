require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::BadgeReportsController, aga_td_list_mock: true, :type => :controller do
  let(:staff) { create :staff }

  it_behaves_like "a report", %w[html csv]

  describe 'html format' do
    it "assigns certain variables" do
      sign_in staff
      get :show, format: 'html', params: { year: staff.year }
      expect(assigns(:attendees)).to_not be_nil
    end
  end

  describe 'csv format' do
    it "succeeds, renders csv" do
      sign_in staff
      get :show, format: 'csv', params: { year: staff.year }
      expect(response).to be_successful
      expect(response.content_type).to eq('text/csv; charset=utf-8')
    end

    it "has one line for each active, planful attendee, plus a header" do
      y = Time.current.year
      3.times { |i|
        # Active attendees with plans
        new_attendee = create :attendee
        plan = create :plan
        new_attendee.plans << plan
      }

      3.times { |i|
        # No plans!
        create :attendee
      }

      3.times { |i|
        # Cancelled!
        new_attendee = create :attendee, cancelled: true
        plan = create :plan
        new_attendee.plans << plan
      }

      sign_in staff
      get :show, format: 'csv', params: { year: y }
      expect(response).to be_successful
      ary = CSV.parse response.body
      expect(ary.size).to eq(4)
    end
  end
end
