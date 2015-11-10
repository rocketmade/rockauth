FactoryGirl.define do
  factory :user, class: Rockauth::User do
    transient do
      build_authentication true
    end

    factory :unauthenticated_user do
      build_authentication false
    end

    email { Faker::Internet.email }
    password { Faker::Internet.password }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    after :build do |instance, evaluator|
      if evaluator.build_authentication
        instance.authentications << build(:registration_authentication, resource_owner: instance)
      end
    end
  end
end
