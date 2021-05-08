class CreateEditableTexts < ActiveRecord::Migration[5.0]
  def change
    create_table :editable_texts do |t|
      t.integer :year
      t.string  :welcome
      t.string  :volunteers
      t.string  :attendees_vip

      t.timestamps
    end
  end
end
