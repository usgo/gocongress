module ApplicationHelper

  def anyone_signed_in?
    # See /lib/devise/controllers/helpers.rb
    signed_in?(nil)
  end

  def asset_file?(subdirectory, filename)
    File.file?(File.join(Rails.root, 'app', 'assets', subdirectory, filename))
  end

  def asset_exists?(path)
    Rails.application.assets.resolve(path).present? 
  end

  # When you want to use `button_to` but your url has a query string
  # https://github.com/rails/rails/issues/2158
  def button_to_get text, url, id, css_class = nil
    render :partial => 'shared/button_to_get', :locals => {
      :btn_txt => text, :btn_url => url, :btn_id => id, :btn_class => css_class}
  end

  def cents_for_currency_field x
    return '' if x.blank?
    cents_to_currency(x, delimiter: '', precision: 2, unit: '')
  end

  def cents_to_currency x, opts = {}
    number_to_currency(x.to_f / 100, opts)
  end

  def image_file?(image)
    asset_file?('images', image)
  end

  def link_to_my_account_or_to_register
    if show_my_account_anchor?
      path = user_path id: current_user.id, year: current_user.year
      link_to "My Account", path
    elsif @year.registration_phase == "open" && @year.year != 2019
      link_to "Start Here", new_user_registration_path
    end
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
    if @year.year != 2016 && @year.year != 2020
      link_to "Youth Attendance Agreement",
        asset_path("liability_release/USGC#{@year.year}-Liability-Release.pdf"),
        :target => '_blank'
    elsif @year.year == 2020
      link_to "Youth Attendance Agreement", "/2020/content_categories/68"
    else
      "Youth Attendance Agreement"
    end
  end

  def link_to_tel text
    return if text.blank?
    sets_of_numbers = text.scan(/[0-9]+/)
    number = "+1-#{sets_of_numbers.join('-')}"
    link_to text, "tel:#{number}"
  end

  def markdown(content)
    @markdown ||= Redcarpet::Markdown.new(MarkdownRenderer, {
      autolink: true,
      space_after_headers: true,
      highlight: true,
      footnotes: true,
      tables: true
    })
    @markdown.render(content)
  end

  def smarty(s)
    Redcarpet::Render::SmartyPants.render(s)
  end

  def markdown_if_present(s)
    s.blank? ? '' : markdown(s).html_safe
  end

  def markdown_summary model, atr, len
    txt = model.send(atr).to_s
    smry_txt = truncate(txt, length: len, separator: ' ')
    html = smry_txt.html_safe
    if txt.length > len
      html += ' '.html_safe + link_to('more', model).html_safe
    end
    markdown(html).html_safe
  end

  def noun_with_article(singular, collection)
    (collection.count == 1) ? "the " + singular : singular.pluralize
  end

  def number_field_for_cents builder, atr, cents
    v = cents_for_currency_field(cents)
    builder.number_field atr, min: 0, size: 5, step: 0.01, value: v
  end
end
