class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    user ||= User.new # guest user (not logged in)
    
    # Admins can do anything
    can :manage, :all if user.is_admin?
    
    # Staff have the same permissions as Users, except they can read anything
    can :read, :all if user.role == 'S'
    
    # Users can manage their own resources only
    
    # Guests can read public resources, but cannot write anything
    can :read, Job
    can :read, Event
    
  end
end
