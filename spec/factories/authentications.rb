FactoryGirl.define do
  factory :authentication, class: Rockauth::Authentication do
    user
    auth_type 'registration'
    client_id { Rockauth::Configuration.clients.first.id }
    client_secret { Rockauth::Configuration.clients.first.secret }

    factory :registration_authentication do

    end

    factory :password_authentication do
      auth_type 'password'

      username { user.email }
      password { user.password }
    end

  end
end
