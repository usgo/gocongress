class PlanCategoriesController < ApplicationController

  load_and_authorize_resource
  before_filter :events_for_select, :only => [:create, :edit, :new, :update]
  before_filter :expose_plans, :only => [:show, :update]

  def index
    categories = @plan_categories \
      .select("plan_categories.*, events.name as event_name") \
      .yr(@year).joins(:event).order("events.name, plan_categories.name")
    @plan_categories_by_event = categories.group_by {|c| c.event_name}
  end

  def show
    @show_availability = Plan.show_availability?(@plans)
  end

  def create
    @plan_category.year = @year
    if @plan_category.save
      redirect_to(@plan_category, :notice => 'Plan category created.')
    else
      render :action => "new"
    end
  end

  def update
    ordering = params[:plan_order] || []

    # coerce the position numbers into integers
    ordering = ordering.map{|x| x.to_i}

    # Only accept orderings that are sequential, start at one, and
    # have a step of one
    sorted_ordering = ordering.sort
    ordering_errors = []
    if sorted_ordering.first != 1
      ordering_errors << "Order must begin with the number one"
    end

    prev = nil
    until sorted_ordering.empty?
      x = sorted_ordering.shift
      if prev.present? && (x - prev != 1)
        ordering_errors << "Order numbers must be sequential"
      end
      prev = x
    end

    if ordering_errors.empty?

      # ranked-model position numbers are zero-indexed,
      # so we subtract one from each
      ordering = ordering.map{|x| x - 1}

      # Save new sort order by going through the plans in the same order
      # they appeared before on the show page.
      if ordering.count == @plans.count
        @plans.each_with_index do |p, ix|
          p.update_attribute :cat_order_position, ordering[ix]
        end
      end
    end

    if ordering_errors.empty? && @plan_category.update_attributes(params[:plan_category])
      redirect_to(@plan_category, :notice => 'Plan category updated.')
    else
      if ordering_errors.empty?
        render :action => "edit"
      else
        @plan_category.errors[:base].concat ordering_errors
        render :action => "show"
      end
    end
  end

  def destroy
    @plan_category.destroy
    redirect_to plan_categories_url
  end

  private

  def events_for_select
    @events_for_select = Event.yr(@year).alphabetical.all.map {|e| [e.name, e.id]}
  end

  def expose_plans
    @plans = @plan_category.plans.rank :cat_order
    @show_order_fields = can?(:update, Plan) && @plans.count > 1
  end

end
