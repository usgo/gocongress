class AddVaccinationProofRequiredToYears < ActiveRecord::Migration[6.0]
  def change
    add_column :years, :vaccination_proof_required, :boolean, default: false
  end
end
