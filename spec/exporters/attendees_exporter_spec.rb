require "spec_helper"

describe AttendeesCsvExporter do

  describe "#attendee_to_array" do
    let(:atnd) { build :attendee }
    let(:ary) { AttendeesCsvExporter.attendee_to_array(atnd) }

    it "returns an array" do
      ary.should be_instance_of(Array)
    end

    it "has the user email in the first element" do
      ary.first.should == atnd.user.email
    end

    it "does not encode entities" do
      str_with_entity = "8>)"
      atnd.special_request = str_with_entity
      ary.should include(str_with_entity)
    end

    it "should have the correct number of elements" do
      create :plan
      na = AttendeesCsvExporter.attendee_attribute_names.length
      np = Plan.yr(atnd.year).count
      ary.should have(na + np + 2).elements
    end
  end
end
