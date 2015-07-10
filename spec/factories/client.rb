
FactoryGirl.define do
  factory :client, class: Rockauth::Client do
    to_create do |instance|
      Rockauth::Config.clients << instance
    end

    sequence(:id) { |n| n.to_s }
    secret { Faker::Internet.password }
    title { Faker::Company.name }
  end
end
