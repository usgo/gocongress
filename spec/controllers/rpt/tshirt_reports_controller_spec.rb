require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::TshirtReportsController, :type => :controller do
  let(:staff) { create :staff }

  it_behaves_like "a report", %w[html]

  describe 'html format' do
    it "assigns certain variables" do
      sign_in staff
      get :show, format: 'html', params: { year: staff.year }
      expect(assigns(:attendees)).to_not be_nil
      expect(assigns(:sizes)).to_not be_nil
      expect(assigns(:total_shirts)).to_not be_nil
    end

    it "creates a shirt size and quantity report based on an attendee list" do
      sign_in staff

      2.times { |i|
        new_attendee = create :attendee, :tshirt_size => 'YS'
        plan = create :plan
        new_attendee.plans << plan
      }

      3.times { |i|
        new_attendee = create :attendee, :tshirt_size => 'YL'
        plan = create :plan
        new_attendee.plans << plan
      }

      4.times { |i|
        new_attendee = create :attendee, :tshirt_size => 'AL'
        plan = create :plan
        new_attendee.plans << plan
      }

      # This attendee has no plan -- they shouldn't be included
      new_attendee = create :attendee, :tshirt_size => 'AL'

      get :show, format: 'html', params: { year: staff.year }

      expect(assigns(:sizes)['YS']).to eq(2)
      expect(assigns(:sizes)['YL']).to eq(3)
      expect(assigns(:sizes)['AL']).to eq(4)
    end
  end
end
