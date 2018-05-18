require "rails_helper"
require "controllers/rpt/shared_examples_for_reports"

RSpec.describe Rpt::MinorAgreementsReportsController, :type => :controller do
  it_behaves_like "a report", %w[html]

  describe "#show" do
    it "shows minors in the correct group" do
      sign_in create :admin

      # One minor has had not their agreement received
      a1 = create :attendee,
        :birth_date => "2006-09-10",
        :guardian_full_name => "Uncle Jimmy"

      # But one minor has!
      a2 = create :attendee,
        :birth_date => "2008-03-12",
        :guardian_full_name => "Aunt Jane",
        :minor_agreement_received => true

      get :show, params: { year: Time.now.year }
      expect(assigns(:minors_without_agreements).map(&:id)).to match_array([a1.id])
      expect(assigns(:minors_with_agreements).map(&:id)).to match_array([a2.id])
    end
  end
end
