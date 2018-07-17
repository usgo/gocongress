require "rails_helper"

RSpec.describe Round::Import, type: :model do
  # TODO import is covered by a feature test but we may want some 
  # unit tests here eventually
  describe "#process!" do
    it "saves game appointments when no errors are present" do
      a_1 = create :attendee, aga_id: 22311
      a_2 = create :attendee, aga_id: 11331
      a_3 = create :attendee, aga_id: 10642
      a_4 = create :attendee, aga_id: 7673
      a_5 = create :attendee, aga_id: 23713
      a_6 = create :attendee, aga_id: 7802
      a_7 = create :attendee, aga_id: 21059
      a_8 = create :attendee, aga_id: 17531
      open_file = File.open("./spec/fixtures/files/sample_tournament_one.xml")

      round = create :round, number: 1
      game_appointment_import = Round::Import.new(file: open_file, round_id: round.id)

      game_appointment_import.process!
      expect(game_appointment_import.imported_game_count).to eq 4 

    end
    it "saves no games if there are aga numbers that don't match" do
      a_1 = create :attendee, aga_id: 99999
      a_2 = create :attendee, aga_id: 11331
      a_3 = create :attendee, aga_id: 10642
      a_4 = create :attendee, aga_id: 7673
      a_5 = create :attendee, aga_id: 23713
      a_6 = create :attendee, aga_id: 7802
      a_7 = create :attendee, aga_id: 21059
      a_8 = create :attendee, aga_id: 17531
      open_file = File.open("./spec/fixtures/files/sample_tournament_one.xml")

      round = create :round, number: 1
      game_appointment_import = Round::Import.new(file: open_file, round_id: round.id)

      game_appointment_import.process!
      expect(game_appointment_import.imported_game_count).to eq 0

    end
    
  end
    
end
