Factory.define :event do |f|
  f.evtname             "eating lasagna"
  f.evtdeparttime       "round about dinner time"
  f.evtprice            "10"
  f.start               2.days.from_now
  f.return_depart_time  Time.now.to_time
  f.return_arrive_time  Time.now.to_time
  f.year                Time.now.year
end
