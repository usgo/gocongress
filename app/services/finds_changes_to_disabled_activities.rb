class FindsChangesToDisabledActivities

  attr_reader :before, :after

  def initialize(before, after)
    @before = before
    @after = after
  end

  def valid?
    invalid_changes.empty?
  end

  private

  # `changes_to_selected_activities`, ie. the symmetric
  # difference (http://bit.ly/aNXT8U) of "before" and "after" sets
  def changes_to_selected_activities
    Set.new(after) ^ before
  end

  def disabled_activities
    Activity.disabled.map(&:id)
  end

  # It is invalid to add or remove disabled activities
  def invalid_changes
    changes_to_selected_activities & disabled_activities
  end
end
