module YearAwareRouteHelpers
  
  # This module is no longer in use now that default_url_options
  # has been added to the application_controller, however I'd
  # like to keep it around for a little while longer in case 
  # the default_url_options approach does not pan out.
  
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    
    # Overrides helper methods like tournaments_path, 
    # and inserts the year before the original path
    def year_aware_route_helpers_for(*resources)
      resources.each do |r|
        rp = r.to_s.pluralize
        
        # These are the route helpers we are going to overwrite
        index_helper = ("#{r.to_s.pluralize}_path").to_sym
        show_helper = ("#{r}_path").to_sym
        new_helper = ("new_#{r}_path").to_sym
        edit_helper = ("edit_#{r}_path").to_sym
        
        # Define year-aware replacement helpers. Note how unexpected arguments
        # are discarded. If we didn't accept these unexpected args, then
        # methods like form_for() would raise a "wrong number of arguments"
        # error. Discarding these arguments could cause trouble in the future.
        
        send :define_method, index_helper do |*unexpected_args|
          "/#{@year}/#{rp}"                                             
        end

        send :define_method, show_helper do |obj, *unexpected_args|
          "/#{@year}/#{rp}/#{obj.id}"                                   
        end

        send :define_method, new_helper do |*unexpected_args|
          "/#{@year}/#{rp}/new"                                         
        end

        send :define_method, edit_helper do |obj, *unexpected_args|         
          "/#{@year}/#{rp}/#{obj.id}/edit"                              
        end
      
        # Now that the year-aware helpers are defined, we must "install" 
        # them by calling helper_method, or else the views will just use 
        # the original helpers.
        helper_method index_helper, show_helper, new_helper, edit_helper
      end
    end

  end

end