module Rockauth
  class MeSerializer < BaseSerializer
    self.root = :user
    attributes :id, :email

    has_one :authentication
    has_many :provider_authentications

    def authentication
      object.authentications.first
    end

    def include_authentication?
      scope.try(:include_authentication?)
    end
  end
end
