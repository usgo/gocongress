Factory.define :transaction do |f|
  f.association :user, :factory => :user
  f.sequence(:gwtranid) { |n| n }
  f.trantype 'S' # sale
  f.gwdate { Factory.next(:gwdate) }
  f.sequence(:amount) { |n| n * 3 }
end

Factory.sequence :gwdate do |n|
  month = rand(11) + 1
  day = rand(27) + 1
  Time.utc(Time.now.year, month, day)
end
