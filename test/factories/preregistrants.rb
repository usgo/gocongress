Factory.define :preregistrant do |f|
  f.country 'US'
  f.firstname 'Amerigo'
  f.lastname 'Vespucci'
  f.email "foo@j.singlebrook.com"
  f.preregdate Time.now
  f.ranktype %w[k d p].sample
  f.rank 3
  f.anonymous false
end
