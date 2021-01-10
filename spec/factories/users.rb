FactoryBot.define do
  factory :user do
    name { "Michael Example" }
    email { "michael@example.com" }
    password_digest { User.digest("password") }
    admin { true }
    activated_at { Time.zone.now }
    state { :active }
  end
end
