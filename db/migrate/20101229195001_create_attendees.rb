class CreateAttendees < ActiveRecord::Migration
  def self.up
    create_table :attendees do |t|
      # First and Last name, and gender ('m', 'f', or nil if declined)
      t.string :given_name, :null => false
      t.string :family_name, :null => false
      t.string :gender, :limit => 1

      # If anonymous, don't show on list of attendees
      t.boolean :anonymous

      # We'll have a mapping of numerical rank to kyu/dan rank
      t.integer :rank, :null => false

      # AGA ID, or nil if not a member
      t.integer :aga_id

      # Address, may be U.S. or international
      t.string :address_1, :null => false
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country

      # Optional contact information
      t.string :phone
      t.string :email

      # Birthdate, so we know if they're a minor or not
      t.date :birth_date

      # Record the fact that they checked the box stating they understand
      # that as a minor, they may not attend unless agreement signed
      # and returned
      t.boolean :understand_minor

      # For admin purposes, mark that we received the minor agreement
      t.boolean :minor_agreement_received

      t.timestamps
    end
  end

  def self.down
    drop_table :attendees
  end
end
