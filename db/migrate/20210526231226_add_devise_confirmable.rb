# frozen_string_literal: true

class AddDeviseConfirmable < ActiveRecord::Migration[5.2]
  def self.up
    change_table :users, bulk: true do |t|
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email
    end
    add_index :users, :confirmation_token, unique: true
  end

  def self.down
    remove_index :users, :confirmation_token
    change_table :users, bulk: true do |t|
      t.remove :confirmation_token
      t.remove :confirmed_at
      t.remove :confirmation_sent_at
      t.remove :unconfirmed_email
    end
  end
end
