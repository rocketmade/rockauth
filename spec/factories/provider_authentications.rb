FactoryGirl.define do
  factory :provider_authentication, class: Rockauth::ProviderAuthentication do
    provider 'facebook'
    sequence(:provider_user_id) { |n| n.to_s }
    provider_access_token { Faker::Internet.password }
    provider_key 'default'
    user
  end
end
