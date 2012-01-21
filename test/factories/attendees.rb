Factory.define :attendee do |f|
  f.address_1 "askldfj"
  f.birth_date "1981-09-10"
  f.city "aaaaaa"
  f.congresses_attended 0
  f.country 'JP'
  f.email "thisgetsoverwrittenanyways@j.singlebrook.com"
  f.family_name 'Vespucci'
  f.gender 'm'
  f.given_name 'Amerigo'
  f.is_current_aga_member true
  f.tshirt_size 'AL'
  f.rank 3
  f.year Time.now.year
end

Factory.define :attendee_minor, :parent => :attendee do |f|
  f.understand_minor true
end

Factory.define :ten_year_old, :parent => :attendee do |f|
  f.birth_date 10.years.ago
  f.understand_minor true
end