module Rockauth
  class MeSerializer < BaseSerializer
    attributes :id

    has_one :authentication
    has_many :provider_authentications

    delegate :include_authentication?, to: :scope, allow_blank: true

    def json_key
      :user
    end

    def authentication
      object.authentications[0]
    end
  end
end
