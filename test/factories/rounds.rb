Factory.define :round do |f|
  f.sequence :round_start do |d|
    d.day.from_now
  end
end
