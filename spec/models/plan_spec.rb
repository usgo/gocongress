require "spec_helper"

describe Plan do
  subject { Factory :all_ages_plan }
  describe "#destroy" do
    it "raises an error if attendees have selected it" do
      subject.attendees << Factory(:attendee)
      expect { subject.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    end
  end
end
