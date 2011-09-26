class ScopeEmailUniquenessIndex < ActiveRecord::Migration
  def up
    remove_index :users, :email
    add_index :users, [:email, :year], :unique => true
  end

  def down
    remove_index :users, :column => [:email, :year]
    add_index :users, :email, :unique => true
  end
end
