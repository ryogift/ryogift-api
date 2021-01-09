FactoryBot.define do
  factory :post do
    user
    content { "test" }
    state { :private }
  end
end
