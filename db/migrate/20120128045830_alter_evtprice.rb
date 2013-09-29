class AlterEvtprice < ActiveRecord::Migration

  class Event < ActiveRecord::Base
  end

  def up
    add_column :events, :price, :decimal, precision: 10, scale: 2
    Event.reset_column_information
    Event.to_a.each do |e|
      e.price = Float(e.evtprice) rescue nil
      e.save!
    end
    remove_column :events, :evtprice
  end

  def down
    remove_column :events, :price
    add_column :events, :evtprice, :string
  end
end
