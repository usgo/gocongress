class AddMailingListLinkToYear < ActiveRecord::Migration[5.2]
  def change
    add_column :years, :mailing_list_link, :string
  end
end
