require "rails_helper"

RSpec.describe AttendeesCsvExporter do

  describe "#attendee_array" do
    let(:atnd) { create :attendee }
    let(:ary) { AttendeesCsvExporter.attendee_array(atnd) }

    it "returns an array" do
      expect(ary).to be_instance_of(Array)
    end

    it "has user_id in the first element" do
      expect(ary.first).to eq(atnd.user_id)
    end

    it "does not encode entities" do
      str_with_entity = "8>)"
      atnd.special_request = str_with_entity
      expect(ary).to include(str_with_entity)
    end

    it "should have the correct number of elements" do
      create :plan
      na = AttendeesCsvExporter::AttendeeAttributes.names.length
      np = Plan.yr(atnd.year).count
      expect(ary.size).to eq(na + np + 6)
    end

    it "should include the guardian's full name" do
      minor = create :minor
      guardian_name = minor.guardian.full_name
      expect(AttendeesCsvExporter.attendee_array(minor)).to include(guardian_name)
    end
  end

  describe '#header_array' do
    let(:header) { AttendeesCsvExporter.header_array(Date.current.year) }

    it "includes guardian" do
      expect(header).to include('guardian')
    end

    it "does not include guardian_attendee_id" do
      expect(header).not_to include('guardian_attendee_id')
    end
  end
end
