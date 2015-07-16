FactoryGirl.define do
  factory :provider_authentication, class: Rockauth::ProviderAuthentication do
    association :resource_owner, factory: :unauthenticated_user
    provider 'facebook'
    sequence(:provider_user_id) { |n| n.to_s }
    provider_access_token { Faker::Internet.password }
  end
end
