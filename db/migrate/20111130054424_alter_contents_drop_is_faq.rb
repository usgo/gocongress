class AlterContentsDropIsFaq < ActiveRecord::Migration
  def change
    remove_column :contents, :is_faq
  end
end
