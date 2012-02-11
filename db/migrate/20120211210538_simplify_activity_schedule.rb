class SimplifyActivitySchedule < ActiveRecord::Migration
  def up
    change_table :activities do |t|
      t.remove :return_depart_time, :depart_time
      t.rename :return_arrive_time, :return
      t.rename :start, :leave
    end
  end

  def down
    change_table :activities do |t|
      t.time :return_depart_time
      t.time :depart_time
      t.rename :return, :return_arrive_time
      t.rename :leave, :start
    end
  end
end
