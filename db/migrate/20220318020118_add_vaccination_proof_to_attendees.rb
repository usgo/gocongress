class AddVaccinationProofToAttendees < ActiveRecord::Migration[6.0]
  def change
    add_column :attendees, :vaccination_proof, :string
  end
end
