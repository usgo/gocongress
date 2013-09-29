module ShirtsHelper
  def link_to_delete shirt
    link_to 'Delete',
      shirt_path(shirt),
      :method => :delete,
      :data => { :confirm => 'Delete? Are you sure?' }
  end
end
