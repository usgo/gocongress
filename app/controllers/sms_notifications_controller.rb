class SmsNotificationsController < ApplicationController
  include YearlyController

  load_resource
  add_filter_to_set_resource_year
  authorize_resource
  add_filter_restricting_resources_to_year_in_route

  def index

  end
end
