class AddWillOfferShirtToYear < ActiveRecord::Migration[6.0]
  def change
    add_column :years, :shirt, :boolean, default: true
  end
end
