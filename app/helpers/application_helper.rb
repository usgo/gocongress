module ApplicationHelper

  def anyone_signed_in?
    # See /lib/devise/controllers/helpers.rb
    signed_in?(nil)
  end

  def format_price(price)
    return price unless floatable?(price)
    price.to_f == 0.0 ? "Free" : number_to_currency(price, :precision => 2)
  end

	def trl_attr ( modelname, attributename )
		# see config/locales/en.yaml
		translate "activerecord.attributes." + modelname.to_s + "." + attributename.to_s
	end

  # The following two helpers come from Ryan Bates' Railscast episodes 196 and 197.
  # They are supposed to be generic, handling any association (model), but I
  # couldn't be bothered to preserve that functionality.  They only handle
  # tournament rounds.  -Jared 1/25/11
  def link_to_add_fields(name, f, association)
    new_object = f.object.class.reflect_on_association(association).klass.new
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(association.to_s.singularize + "_fields", :f => builder)
    end
    link_to_function(name, "add_round(this, \"#{association}\", \"#{escape_javascript(fields)}\")")
  end

  def link_to_remove_fields( anchor_text, f)
    f.hidden_field(:_destroy, :class => 'tournament-round-destroy') + link_to_function( anchor_text, "remove_round(this)" )
  end

  def markdown_if_present(s)
    s.blank? ? '' : Markdown.new(s).to_html.html_safe
  end

  def floatable?(object)
    true if Float(object) rescue false
  end

end
