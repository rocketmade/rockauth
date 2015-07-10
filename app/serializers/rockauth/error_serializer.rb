module Rockauth
  class ErrorSerializer < BaseSerializer
    attributes(*%i(status_code message validation_errors))
  end
end
