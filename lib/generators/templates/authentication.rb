class Authentication < Rockauth::Authentication
  belongs_to :provider_authentication, class_name: "::ProviderAuthentication"
end
