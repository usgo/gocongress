module ActivityCategoriesHelper
  def button_to_delete cat
    button_to "Delete this Category",
      cat, :method => "delete",
      :data => {:confirm => 'Delete this category and all activities in it? Are you sure?'}
  end

  def button_to_edit cat
    button_to "Edit this Category",
      edit_activity_category_path(cat), :method => "get"
  end
end
