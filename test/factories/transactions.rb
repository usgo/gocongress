Factory.define :transaction do |f|
  f.association :user, :factory => :user
  f.sequence(:amount) { |n| n * 3 }
end

Factory.define :tr_comp, :parent => :transaction do |f|
  f.trantype 'C' # comp
end

Factory.define :tr_sale, :parent => :transaction do |f|
  f.trantype 'S' # sale
  f.gwdate { Factory.next(:gwdate) }
  f.sequence(:gwtranid) { |n| n }
end

Factory.sequence :gwdate do |n|
  month = rand(11) + 1
  day = rand(27) + 1
  Time.utc(Time.now.year, month, day)
end
