module ApplicationHelper

  def anyone_signed_in?
    # See /lib/devise/controllers/helpers.rb
    signed_in?(nil)
  end

	def trl_attr_for_model ( modelname, attributename )
		# see config/locales/en.yaml
		translate "activerecord.attributes." + modelname + "." + attributename
	end

end
