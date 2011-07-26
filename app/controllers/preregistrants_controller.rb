class PreregistrantsController < ApplicationController

  load_and_authorize_resource

  def index
    @preregistrants = @preregistrants.order 'preregdate asc'
  end

end
