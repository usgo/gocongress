class AddCovidPolicyAgreementToAttendees < ActiveRecord::Migration[6.0]
  def change
    add_column :attendees, :agree_to_covid_policy, :boolean, default: false
  end
end
