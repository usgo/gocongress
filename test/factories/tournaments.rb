Factory.define :tournament do |f|
  f.sequence(:name) { |n| "Tournament #{n}"}
  f.eligible "blah"
  f.description "blah"
  f.directors "blah"
  f.openness "O"
end
