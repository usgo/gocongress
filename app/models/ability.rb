class Ability
  include CanCan::Ability

  # Define an array of all resource classes, to be used
  # when the cancan syntax does not allow the symbol :all
  # For example, when applying conditions, eg. :year
  ALL_RESOURCES = [
    Activity,
    ActivityCategory,
    Attendee,
    Contact,
    Content,
    ContentCategory,
    EditableText,
    Event,
    GameAppointment,
    Plan,
    PlanCategory,
    Round,
    Shirt,
    SmsNotification,
    Tournament,
    Transaction,
    User,
    Year
  ]

  def initialize(user)
    # Guests can read public resources, but cannot write anything
    can :read, [Contact, Content, ContentCategory, Activity,
      Shirt, Tournament, PlanCategory, Round, GameAppointment]

    # Guests can show (but not index) the following:
    can :show, ActivityCategory
    can :show, Plan, :disabled => false
    can :show, Plan, :show_disabled => true

    # That's the end of guest permissions.
    return if user.nil?

    # Admins can do anything in their own year
    if user.admin? then
      can :manage, ALL_RESOURCES, :year => user.year
    end

    # Staff can read anything in their own year
    if user.role == 'S' then
      can :read, ALL_RESOURCES, :year => user.year
    end

    # Admins and Staff share a few special abilities
    if user.admin? or user.role == 'S' then
      can :print_official_docs, User, :year => user.year
      can :check_in, :attendee
      can :read, :report
      can :see_admin_menu, :layout
    end

    # User and Staff can manage their own resources, except for
    # their User record, which they can only show and update.
    # Users specifically cannot :read, because that implies :index.
    if %w[S U].include?(user.role) then
      can [:show, :update], User, :id => user.id
      can :manage, Attendee, :user_id => user.id
      cannot :list, Attendee if user.role == 'U'
    end
  end

  # `explain_denial` provides a friendly "access denied" message
  def self.explain_denial(authenticated, action, plural_model)
    (authenticated ? 'You are signed in, but' : 'You are not signed in, so of course') +
    ' you do not have permission to ' + explain_action(action) + ' ' +
    singularize_if(plural_model, [:destroy, :show].include?(action)) + '.'
  end

  private

  def self.explain_action act
    explanations = {destroy: 'delete this', index: 'list', show: 'see this'}
    return explanations[act.to_sym] || act.to_s
  end

  def self.singularize_if plural, bool
    bool ? plural.singularize : plural
  end

end
