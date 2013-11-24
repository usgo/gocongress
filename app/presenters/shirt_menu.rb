class ShirtMenu
  extend ActionView::Helpers::FormOptionsHelper

  def self.to_html f, year, selected_shirt_id
    s = shirts(year, selected_shirt_id)
    if s.size == 0
      "TBD"
    else
      f.select :shirt_id, options(s, selected_shirt_id), :include_blank => ''
    end
  end

  private

  def self.options shirt_set, selected_shirt_id
    options_from_collection_for_select(
      shirt_set, :id, :name, selected = selected_shirt_id)
  end

  def self.selected_shirt_array id
    begin
      [Shirt.find(id)]
    rescue ActiveRecord::RecordNotFound
      []
    end
  end

  def self.shirts year, selected_shirt_id
    Set.new(Shirt.yr(year).enabled).merge(selected_shirt_array(selected_shirt_id)).to_a
  end
end
