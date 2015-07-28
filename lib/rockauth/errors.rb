require 'active_model'

module Rockauth
  module Errors
    ControllerError = Struct.new(:status_code, :message, :validation_errors) do
      include ActiveModel::Serialization
      def self.active_model_serializer
        Rockauth::Configuration.serializers.error.safe_constantize
      end
    end
  end
end
