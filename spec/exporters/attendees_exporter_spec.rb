require "spec_helper"

describe AttendeesCsvExporter do

  describe "#attendee_to_array" do
    let(:atnd) { build :attendee }

    it "returns an array" do
      AttendeesCsvExporter.attendee_to_array(atnd).should be_instance_of(Array)
    end

    it "does not encode entities" do
      str_with_entity = "8>)"
      atnd.special_request = str_with_entity
      AttendeesCsvExporter.attendee_to_array(atnd).should include(str_with_entity)
    end
  end
end
