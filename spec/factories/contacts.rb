FactoryBot.define do
  factory :contact do
    title { "Registrar" }
    given_name { "Jane" }
    family_name { "Doe" }
    list_order { 42 }
    email { "janedoe@example.com" }
    year { Time.now.year }
  end
end
