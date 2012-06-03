module ApplicationHelper

  def anyone_signed_in?
    # See /lib/devise/controllers/helpers.rb
    signed_in?(nil)
  end

  def disabled_checkbox
    '<input type="checkbox" disabled="disabled" />'.html_safe
  end

	# `trl_attr` is slightly more convenient than
	# Model.human_attribute_name("attr")
	def trl_attr ( modelname, attributename )
		translate "activerecord.attributes." + modelname.to_s + "." + attributename.to_s
	end

  # An English list is comma delimited, and the final element
  # is prepended with a word like 'and'.
  def join_english_list list, word = "and"
    raise ArgumentError, "Expected enumerable" unless list.respond_to? :each
    return list.first.to_s if list.count == 1
    return list.slice(0, list.count - 1).join(", ") + ", " + word + " " + list.last.to_s
  end

  def link_to_liability_release()
    link_to "Liability Release",
      "/docs/liability_release/USGC#{@year.year}-Liability-Release.pdf",
      :target => '_blank'
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

  def noun_with_article(singular, collection)
    (collection.count == 1) ? "the " + singular : singular.pluralize
  end

  def production?
    ENV['RAILS_ENV'] == 'production'
  end

end
