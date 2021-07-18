module EditableTextsHelper
  def editable_text(name)
    markdown(
      EditableText
        .select(name)
        .find_or_create_by(year: @year.year)[name]
    ).html_safe
  end
end
