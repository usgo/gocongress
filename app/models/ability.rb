class Ability
  include CanCan::Ability

  def initialize(user)
    all_resources = Ability.congress_resources

    # If there is no user logged in, instantiate a guest user.
    # Be sure to set the role to the empty string, or else
    # ActiveRecord will use the database default, which is 'U'!
    if user.nil?
      user = User.new
      user.role = '' # we cannot pass role to new() because role is attr_protected
    end
    
    # Admins can do anything in their own year
    if user.is_admin? then
      can :manage, all_resources, :year => user.year
    end
    
    # Staff can read anything in their own year
    if user.role == 'S' then
      can :read, all_resources, :year => user.year
    end

    # Admins and Staff share a few special abilities
    if user.is_admin? or user.role == 'S' then
      can :print_official_docs, User, :year => user.year
      can :read, :report
      can :see_admin_menu, :layout
    end
    
    # User and Staff can manage their own resources, except for 
    # their User record, which they can only show and update
    if %w[S U].index(user.role).present? then
      can [:show, :update], User, :id => user.id
      can :manage, Attendee, :user_id => user.id
    end
    
    # Guests can read public resources, but cannot write anything
    can :read, [Content, ContentCategory, Event, Job, Tournament, PlanCategory]
    can :show, [Plan, EventCategory]
    
    # Possibly defunct
    can :faq, Content
  end

  def self.congress_resources
    # Define an array of all resource classes, to be used
    # when the cancan syntax does not allow the symbol :all
    # For example, when applying conditions, eg. :year
    [Attendee,Content,ContentCategory,Discount,Event,EventCategory,
      Job,PlanCategory,Plan,Transaction,Tournament,User]
  end

end
