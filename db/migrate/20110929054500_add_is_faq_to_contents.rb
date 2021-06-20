class AddIsFaqToContents < ActiveRecord::Migration
  def up
    add_column :contents, :is_faq, :boolean
    Content.update_all :is_faq => false
    change_column :contents, :is_faq, :boolean, :null => false
  end

  def down
    remove_column :contents, :is_faq
  end
end
