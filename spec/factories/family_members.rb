FactoryBot.define do
  factory :family_member do
    first_name { "MyString" }
    last_name { "MyString" }
    date_of_birth { "2025-02-11" }
    date_of_death { "2025-02-11" }
    family { nil }
  end
end
