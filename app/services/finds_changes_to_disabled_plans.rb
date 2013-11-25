class FindsChangesToDisabledPlans

  attr_reader :before, :after

  def initialize(before, after)
    @before = before
    @after = after
  end

  def removal_errors
    disableds(Set.new(before) - after).map do |ap|
      msg_re_change_to_disabled_plan(ap.plan.name, "remove")
    end
  end

  def addition_errors
    disableds(Set.new(after) - before).map do |ap|
      msg_re_change_to_disabled_plan(ap.plan.name, "select")
    end
  end

  private

  def disableds(ary)
    ary.select { |ap| ap.plan.disabled? }
  end

  def msg_re_change_to_disabled_plan plan_name, verb
    "One of the plans you tried to #{verb} (#{plan_name}) has been disabled to prevent changes.  Please contact the registrar."
  end

end
