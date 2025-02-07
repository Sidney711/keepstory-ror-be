FactoryBot.define do
  factory :account do
    email { Faker::Internet.unique.email }
    password_hash { RodauthApp.rodauth.allocate.password_hash("password") }
    status { "verified" }
  end
end
