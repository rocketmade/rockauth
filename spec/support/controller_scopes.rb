module ControllerScopeParameterInjection
  %i{get post patch put delete}.each do |meth|
    define_method meth do |*args, &block|
      if defined?(resource_owner_class_name)
        if args.last.is_a?(Hash)
          unless args.last.has_key?(:resource_owner_class_name)
            args.last[:resource_owner_class_name] = resource_owner_class_name
          end
        else
          args.push(resource_owner_class_name: resource_owner_class_name)
        end
      end
      super *args, &block
    end
  end
end

RSpec.shared_context :resource_owner_class_name, type: :controller do
  let(:resource_owner_class_name) { 'Rockauth::User' }
end

RSpec.configure do |config|
  config.include ControllerScopeParameterInjection, type: :controller
end
