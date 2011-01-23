class AddToJobs < ActiveRecord::Migration
  def self.up
    add_column :jobs, :total_needed, :integer
    add_column :jobs, :vacancies, :integer
    add_column :jobs, :description, :text
  end

  def self.down
    remove_column :jobs, :total_needed
    remove_column :jobs, :vacancies
    remove_column :jobs, :description
  end
end
