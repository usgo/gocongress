class DropUniqueIndexOnGwtranid < ActiveRecord::Migration
  def up
    remove_index :transactions, :gwtranid
  end

  def down
    # unique validation in model also
    add_index :transactions, :gwtranid, :unique => true
  end
end
