Factory.define :transaction do |f|
  f.association :user, :factory => :user
  f.gwdate { Factory.next(:gwdate) }
  f.sequence(:amount) { |n| n * 3 }
end

Factory.define :tr_discount, :parent => :transaction do |f|
  f.trantype 'D' # discount
end

Factory.define :tr_sale, :parent => :transaction do |f|
  f.trantype 'S' # sale
  f.sequence(:gwtranid) { |n| n }
end

Factory.sequence :gwdate do |n|
  month = rand(11) + 1
  day = rand(27) + 1
  Time.utc(Time.now.year, month, day)
end
