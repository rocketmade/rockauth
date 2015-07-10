FactoryGirl.define do
  factory :user, class: Rockauth::User do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    after :build do |instance|
      instance.authentications << build(:registration_authentication, user: instance)
    end
  end
end
