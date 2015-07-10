FactoryGirl.define do
  factory :authentication, class: Rockauth::Authentication do
    user
    auth_type 'registration'
    client_id { Rockauth::Config.clients.first.id }
    client_secret { Rockauth::Config.clients.first.secret }

    factory :registration_authentication do

    end

    factory :password_authentication do
      auth_type 'password'

      username { user.email }
      password { user.password }
    end

  end
end
