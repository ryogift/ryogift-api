FactoryBot.define do
  factory :post do
    user
    content { "test" }
  end
end
