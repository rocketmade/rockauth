module Rockauth
  class MeSerializer < ActiveModel::Serializer
    attributes :id
    has_many :provider_authentications
  end
end
