FactoryGirl.define do
  factory :provider_authentication, class: Rockauth::ProviderAuthentication do
    association :resource_owner, factory: :unauthenticated_user
    provider 'facebook'
    provider_access_token { Faker::Internet.password }

    factory :predefined_provider_authentication do
      skip_provider_authentication true
      sequence(:provider_user_id) { |n| n.to_s }
    end
  end
end
