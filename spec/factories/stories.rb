FactoryBot.define do
  factory :story do
    title { "MyString" }
    content { "MyText" }
    date_type { "MyString" }
    story_date { "2025-02-12" }
    story_year { 1 }
    is_date_approx { false }
    family { nil }
  end
end
