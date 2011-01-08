class AlterAttendeeDotMinorAgreementReceived < ActiveRecord::Migration
  def self.up
		remove_column(:attendees, :minor_agreement_received)
  	add_column(:attendees, :minor_agreement_received, :boolean, {:null => false, :default => false})
  end

  def self.down
  	change_column(:attendees, :minor_agreement_received, :boolean, {:null => true})
  end
end
