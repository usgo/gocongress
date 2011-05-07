class PreregistrantsController < ApplicationController

  # Access Control
  before_filter :allow_only_admin

  def index
    @preregistrants = Preregistrant.order('preregdate asc')
  end

end
