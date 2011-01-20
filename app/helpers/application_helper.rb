module ApplicationHelper

	def trl_attr_for_model ( modelname, attributename )
		# see config/locales/en.yaml
		translate "activerecord.attributes." + modelname + "." + attributename
	end

end
