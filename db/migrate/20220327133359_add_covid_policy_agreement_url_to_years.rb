class AddCovidPolicyAgreementUrlToYears < ActiveRecord::Migration[6.0]
  def change
    add_column :years, :covid_policy_url, :string
  end
end
