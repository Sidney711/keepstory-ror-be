FactoryBot.define do
  factory :additional_datum do
    family_member { nil }
    attribute_name { "MyString" }
    short_text { "MyString" }
    long_text { "MyString" }
  end
end
