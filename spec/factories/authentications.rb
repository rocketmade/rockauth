FactoryGirl.define do
  factory :authentication, class: Rockauth::Authentication do
    user
    auth_type 'password'
    password { user.password }
    email { user.email }
  end
end
