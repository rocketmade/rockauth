require 'active_model'

module Rockauth
  module Errors
    class ControllerError < Struct.new(:status_code, :message, :validation_errors)
      include ActiveModel::Serialization
    end
  end
end
