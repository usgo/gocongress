module ActivityCategoriesHelper

  def button_to_delete cat
    button_to "Delete this #{ActivityCategory.model_name.human}",
      cat, :method => "delete",
      :confirm => 'Really delete this category and all activities in it? Are you sure?'
  end

end
