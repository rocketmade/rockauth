module Rockauth
  class UserSerializer < BaseSerializer
    attributes :id, :email, :first_name, :last_name

    has_one :authentication
    has_many :provider_authentications

    def root
      'user'
    end

    def authentication
      object.authentications.first
    end

    def include_authentication?
      current_resource_owner? && scope.try(:include_authentication?)
    end

    def current_resource_owner?
      scope.try(:current_resource_owner) == object
    end

    alias :include_provider_authentications? :current_resource_owner?
    alias :include_email? :current_resource_owner?
  end
end
