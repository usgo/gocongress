class ReplaceIsPlayer < ActiveRecord::Migration
  # Faux models protect against validations which may be added in future
  # http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  # But, if I had to do this again, I'd just write SQL!
  class PlanCategory < ActiveRecord::Base
    include YearlyModel
    has_many :plans
  end

  class Plan < ActiveRecord::Base
    include YearlyModel
    has_many :attendee_plans, :dependent => :destroy
    has_many :attendees, :through => :attendee_plans
  end

  class AttendeePlan < ActiveRecord::Base
    include YearlyModel
    belongs_to :attendee
    belongs_to :plan
  end

  class Attendee < ActiveRecord::Base
    include YearlyModel
    has_many :attendee_plans, :dependent => :destroy
    has_many :plans, :through => :attendee_plans
  end

  def up
    # In order to drop attendees.is_player, we must first migrate
    # data from 2011, by creating plans and assigning attendees.
    # This effort is not necessary in 2012, because we have no
    # attendees yet.

    # 2011 had a plan category that represented registrations, but
    # it was just for show.  Attendees were not allowed to select
    # the plans in that category.
    PlanCategory.yr(2011).where(name: "Registration", show_on_reg_form: false).destroy_all

    # Create a new plan category for 2011 to represent registrations.
    cat = PlanCategory.yr(2011).create(
      year: 2011,
      name: "Registration",
      show_on_reg_form: true
    )

    # The new registration category will have two records:
    plan_specs = []
    plan_specs << {stem: "Player", price: 375}
    plan_specs << {stem: "Non-Player", price: 75}
    plan_specs.each do |p|
      plan_name = "#{p[:stem]} Registration"
      cat.plans.create(
        year: 2011,
        name: plan_name,
        price: p[:price],
        age_min: 0,
        description: plan_name
      )
    end

    # Check that the category has the expected number of plans
    unless cat.plans.count == plan_specs.count
      raise "Expected #{plan_specs.count} plans in category, found #{cat.plans.count}"
    end

    # Now that we have found (or seeded) the required 2011 plans,
    # we may begin assigning them to their respective 2011 attendees
    Attendee.yr(2011).each do |a|
      cat.plans.each do |p|
        if a.is_player ^ (p.name == "Non-Player Registration")
          AttendeePlan.create!(:attendee_id => a.id, :plan_id => p.id, :quantity => 1, :year => 2011)
        end
      end
    end

    # Check that the count of assigned plans matches the count of 2011 attendees
    plan_count = cat.plans.map{|p| p.attendees.count}.reduce(:+)
    unless plan_count == Attendee.yr(2011).count
      raise "Expected #{Attendee.yr(2011).count} plans to be assigned, found #{plan_count}"
    end

    # And finally, we may drop the is_player column!
    remove_column :attendees, :is_player
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
