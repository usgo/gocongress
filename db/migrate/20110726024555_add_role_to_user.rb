class AddRoleToUser < ActiveRecord::Migration
  def up
    count_admins_before = User.where(:is_admin => true).count
    add_column :users, :role, :string, {:limit => 1, :null => false, :default => 'U'}
    User.update_all "role = 'A'", "is_admin = 't'"
    count_admins_after = User.where(:role => 'A').count
    raise "counts do not match" if count_admins_before != count_admins_after
    remove_column :users, :is_admin
  end

  def down
    raise IrreversibleMigration
  end
end
