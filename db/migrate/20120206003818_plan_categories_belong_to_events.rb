class PlanCategoriesBelongToEvents < ActiveRecord::Migration
  include PostgresMigrationHelpers

  class Event < ActiveRecord::Base
  end

  class PlanCategory < ActiveRecord::Base
  end

  def up
    add_column :plan_categories, :event_id, :integer

    # Update 2011 Plan Categories
    e = Event.create! name: "Congress 2011", year: 2011
    PlanCategory.where(year: 2011).update_all(event_id: e.id)

    # Update 2012 Plan Categories
    e = Event.create! name: "Congress 2012", year: 2012
    PlanCategory.where(year: 2012).update_all(event_id: e.id)

    # Add foreign key
    add_index :events, [:id, :year], :unique => true
    add_pg_foreign_key :plan_categories, [:event_id, :year], :events, [:id, :year]

    # Add not-null constraint
    change_column :plan_categories, :event_id, :integer, :null => false
  end

  def down
    remove_pg_foreign_key :plan_categories, [:event_id, :year]
    remove_column :plan_categories, :event_id
  end
end
