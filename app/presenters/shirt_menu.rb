class ShirtMenu
  extend ActionView::Helpers::FormOptionsHelper

  def self.to_html f, selected_shirt_id
    f.select :shirt_id, options(selected_shirt_id), :include_blank => ''
  end

  private

  def self.options selected_shirt_id
    options_from_collection_for_select(
      shirts(selected_shirt_id), :id, :name, selected = selected_shirt_id)
  end

  def self.selected_shirt_array id
    begin
      [Shirt.find(id)]
    rescue ActiveRecord::RecordNotFound
      []
    end
  end

  def self.shirts selected_shirt_id
    Set.new(Shirt.enabled).merge(selected_shirt_array(selected_shirt_id)).to_a
  end
end
