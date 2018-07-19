require 'rails_helper'

RSpec.describe GameAppointment, type: :model do
  before do
    @game_appointment = FactoryBot.build_stubbed(:game_appointment)
  end

  it "has a valid factory" do
    expect(@game_appointment).to be_valid
  end

  describe 'validations' do
    it 'it should be required to belong to a round' do
      @game_appointment.round_id = nil
      expect(@game_appointment).to_not be_valid
    end

    it 'it should be required to have an attendee_one association' do
      @game_appointment.attendee_one = nil
      expect(@game_appointment).to_not be_valid
    end

    it 'it should be required to have an attendee_two association' do
      @game_appointment.attendee_two = nil
      expect(@game_appointment).to_not be_valid
    end

    it 'it should always have a table' do
      @game_appointment.table = nil
      expect(@game_appointment).to_not be_valid
    end

    it 'it should always have a location' do
      @game_appointment.location = nil
      expect(@game_appointment).to_not be_valid
    end

    it 'it should be required to have a time' do
      @game_appointment.time = nil
      expect(@game_appointment).to_not be_valid
    end

  end

end
