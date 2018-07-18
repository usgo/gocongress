require "rails_helper"

RSpec.describe Round::Import, type: :model do
  # TODO import is covered by a feature test but we may want some 
  # unit tests here eventually
  describe "#process!" do
    it "saves game appointments and byes when no errors are present" do
      create :attendee, aga_id: 22311
      create :attendee, aga_id: 11331
      create :attendee, aga_id: 10642
      create :attendee, aga_id: 7673
      create :attendee, aga_id: 23713
      create :attendee, aga_id: 7802
      create :attendee, aga_id: 21059
      create :attendee, aga_id: 17531
      create :attendee, aga_id: 15932
      open_file = File.open("./spec/fixtures/files/sample_tournament_one.xml")

      round = create :round, number: 1
      game_appointment_import = Round::Import.new(file: open_file, round_id: round.id)

      game_appointment_import.process!
      expect(game_appointment_import.imported_game_count).to eq 4 
      expect(game_appointment_import.imported_bye_count).to eq 1 

    end
    it "saves no games if there are aga numbers that don't match" do
      create :attendee, aga_id: 99999
      create :attendee, aga_id: 11331
      create :attendee, aga_id: 10642
      create :attendee, aga_id: 7673
      create :attendee, aga_id: 23713
      create :attendee, aga_id: 7802
      create :attendee, aga_id: 21059
      create :attendee, aga_id: 17531
      open_file = File.open("./spec/fixtures/files/sample_tournament_one.xml")

      round = create :round, number: 1
      game_appointment_import = Round::Import.new(file: open_file, round_id: round.id)

      game_appointment_import.process!
      expect(game_appointment_import.imported_game_count).to eq 0
      expect(game_appointment_import.imported_bye_count).to eq 0

    end
    
  end
    
end
