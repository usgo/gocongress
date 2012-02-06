class Ability
  include CanCan::Ability

  # Define an array of all resource classes, to be used
  # when the cancan syntax does not allow the symbol :all
  # For example, when applying conditions, eg. :year
  ALL_RESOURCES = [Activity, ActivityCategory, Attendee, Content,
    ContentCategory, Discount, Event, Job, PlanCategory, Plan,
    Transaction, Tournament, User]

  def initialize(user)

    # If there is no user logged in, instantiate a guest user.
    # Be sure to set the role to the empty string, or else
    # ActiveRecord will use the database default, which is 'U'!
    if user.nil?
      user = User.new
      user.role = '' # we cannot pass role to new() because role is attr_protected
    end

    # Admins can do anything in their own year
    if user.is_admin? then
      can :manage, ALL_RESOURCES, :year => user.year
    end

    # Staff can read anything in their own year
    if user.role == 'S' then
      can :read, ALL_RESOURCES, :year => user.year
    end

    # Admins and Staff share a few special abilities
    if user.is_admin? or user.role == 'S' then
      can :print_official_docs, User, :year => user.year
      can :read, :report
      can :see_admin_menu, :layout
    end

    # User and Staff can manage their own resources, except for
    # their User record, which they can only show and update
    if %w[S U].include?(user.role) then
      can [:show, :update], User, :id => user.id
      can :manage, Attendee, :user_id => user.id
    end

    # Guests can read public resources, but cannot write anything
    can :read, [Content, ContentCategory, Activity, Job, Tournament, PlanCategory]
    can :show, [Plan, ActivityCategory]
  end
end
