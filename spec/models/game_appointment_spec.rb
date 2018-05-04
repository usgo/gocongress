require 'rails_helper'

RSpec.describe GameAppointment, type: :model do
  before do
    @game_appointment = FactoryBot.create(:game_appointment)
  end
  describe 'create' do
    it 'can be properly created' do
      expect(@game_appointment).to be_valid
    end
  end

  describe 'validations' do
    it 'it should be required to have a tournament association' do
      @game_appointment.user_id = nil
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

    it 'it should have a start date equal to 6 days prior' do
      new_audit_log = AuditLog.create(user_id: User.last.id)
      expect(new_audit_log.start_date).to eq(Date.today - 6.days)
    end
  end

end
