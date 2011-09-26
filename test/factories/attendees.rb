Factory.define :attendee do |f|
  f.address_1 "askldfj"
  f.birth_date "1981-09-10"
  f.city "aaaaaa"
  f.country 'JP'
  f.gender 'm'
  f.given_name 'Amerigo'
  f.family_name 'Vespucci'
  f.email "thisgetsoverwrittenanyways@j.singlebrook.com"
  f.tshirt_size 'AL'
  f.rank 3
  f.year Time.now.year
end

Factory.define :ten_year_old, :parent => :attendee do |f|
  f.birth_date 10.years.ago
  f.understand_minor true
end