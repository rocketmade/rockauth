require 'active_model_serializers'
module Rockauth
  class BaseSerializer < ActiveModel::Serializer
    # embed :ids, include: true
  end
end
