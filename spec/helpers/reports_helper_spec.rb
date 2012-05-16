describe ReportsHelper do
  describe "#attendee_to_array" do
    it "returns an array" do
      atnd = FactoryGirl.build :attendee
      helper.attendee_to_array(atnd).should be_instance_of(Array)
    end
  end
end