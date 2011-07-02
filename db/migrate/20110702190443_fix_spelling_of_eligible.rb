class FixSpellingOfEligible < ActiveRecord::Migration
  def up
    rename_column :tournaments, :elligible, :eligible
  end

  def down
    rename_column :tournaments, :eligible, :elligible
  end
end
