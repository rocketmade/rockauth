require 'active_model'

module Rockauth
  module Errors
    ControllerError = Struct.new(:status_code, :message, :validation_errors) do
      extend ActiveModel::Naming
      include ActiveModel::Serialization

      def self.model_name
        'Error'
      end

      def self.active_model_serializer
        Rockauth::Configuration.serializers.error.safe_constantize
      end
    end
  end
end
