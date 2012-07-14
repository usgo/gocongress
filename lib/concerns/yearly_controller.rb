module YearlyController
  extend ActiveSupport::Concern

  module ClassMethods

    # Instead of adding the callbacks using `included()`, make the
    # controller class explicitly add them.  This is less mysterious
    # and helps the controller class to adjust the order of callbacks,
    # while keeping all includes at the top. -Jared 2012-07-14
    def add_yearly_controller_callbacks
      before_filter :set_year_from_route_and_authorize, :only => [:create, :new]
      before_filter :ensure_rsrc_year_matches_route_year, :except => [:create, :index, :new]
    end

  end

  # When our before filters run, we need @year to have been set
  # by `set_year_from_params`, so we `check_that_year_is_present`.
  def check_that_year_is_present
    raise "undefined year" if @year.nil?
  end

  # If any user tries to access a resource while using the wrong
  # year's "site", we don't want them to see the resource because
  # that could be very misleading.  However, this is unlikely to
  # happen. Barring a badly generated URL, the user would have to
  # edit the URL manually, changing the year or the resource id.
  def ensure_rsrc_year_matches_route_year

    # If there's no :id parameter, then skip this validation.
    return if params[:id].blank?

    check_that_year_is_present

    # Try to load the resource by id.  This can throw
    # RecordNotFound, but that would happen later anyway
    # when cancan (or whatever) loads the resource.
    model_class = controller_name.classify.constantize
    resource = model_class.find(params[:id])

    # If we find the resource and it doesn't belong to the year
    # in the route, then raise RecordNotFound which should get
    # rescued as a 404 in production.
    if resource.year != @year.year
      raise ActiveRecord::RecordNotFound, \
        "Resource year (#{resource.year}) does not match route year (#{@year.year})"
    end
  end

  # Access control across years is forbidden by cancan.  However,
  # on `create` and `new` cancan will initialize the resource using
  # the ability conditions, which could be a different year than
  # the route year.  Eg. a 2012 admin could try to use a 2011 form.
  def set_year_from_route_and_authorize
    check_that_year_is_present

    # Hopefully cancan's `load_resource` has already run
    ivar_name = "@" + controller_name.singularize.downcase
    ivar = self.instance_variable_get ivar_name
    raise "expected cancan to have initialized #{ivar_name} by now" if ivar.nil?

    # Finally, set year from route and authorize!
    ivar.year = @year.year
    authorize! :create, ivar
  end

end
