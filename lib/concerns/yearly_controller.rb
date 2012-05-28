module YearlyController
  extend ActiveSupport::Concern

  included do
    before_filter :ensure_resource_year_matches_year_in_route
  end

  # If any user tries to access a resource while using the wrong
  # year's "site", we don't want them to see the resource because
  # that could be very misleading.  However, this is unlikely to
  # happen. Barring a badly generated URL, the user would have to
  # edit the URL manually, changing the year or the resource id.
  # On an unrelated note, access control across years (always
  # forbidden) is handled separately by cancan.
  def ensure_resource_year_matches_year_in_route
    return if params[:id].blank?

    # Hopefully the @year has already been set by `set_year_from_params`
    raise "undefined year" if @year.nil?

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
end
