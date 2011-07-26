class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    user ||= User.new # guest user (not logged in)
    
    # Admins can do anything
    can :manage, :all if user.is_admin?
    
    # Staff have the same permissions as Users, except they can read anything
    if user.role == 'S' then
      can :read, :all
      can :see_admin_menu, :layout
    end
    
    # Users can manage their own resources only
    if user.role == 'U' then
      can :manage, User, :id => user.id
    end
    
    # Guests can read public resources, but cannot write anything
    can :read, Job
    can :read, Event
    
  end
end
