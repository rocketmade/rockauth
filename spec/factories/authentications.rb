FactoryGirl.define do
  factory :authentication, class: Rockauth::Authentication do
    association :resource_owner, factory: :unauthenticated_user
    auth_type 'registration'
    client_id { Rockauth::Configuration.clients.first.id }
    client_secret { Rockauth::Configuration.clients.first.secret }
    resource_owner_class Rockauth::User

    factory :registration_authentication do

    end

    factory :invalid_authentication do
      auth_type 'password'
      username nil
      password nil
    end

    factory :password_authentication do
      auth_type 'password'
      username { resource_owner.email }
      password { resource_owner.password }
    end

  end
end
