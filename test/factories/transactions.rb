Factory.define :transaction do |f|
  f.association :user, :factory => :user
  f.association :updated_by_user, :factory => :user
  f.sequence(:amount) { |n| n * 3 }
end

Factory.define :tr_comp, :parent => :transaction do |f|
  f.trantype 'C' # comp
  f.instrument nil
end

Factory.define :tr_refund, :parent => :transaction do |f|
  f.trantype 'R'
  f.instrument %w[K S].sample
end

Factory.define :tr_sale, :parent => :transaction do |f|
  f.trantype 'S' # sale
  ins = %w[C S K].sample
  f.instrument ins
  case ins
  when 'C'
    f.gwdate { Factory.next(:gwdate) }
    f.sequence(:gwtranid) { |n| n }
  when 'K'
    f.check_number 101
  end
end

Factory.sequence :gwdate do |n|
  month = rand(11) + 1
  day = rand(27) + 1
  Time.utc(Time.now.year, month, day)
end
