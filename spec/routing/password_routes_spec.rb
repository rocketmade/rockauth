require 'spec_helper'

describe 'provider authentications routes' do
  it 'routes POST /passwords/forgot to forgot' do
    expect(POST: '/passwords/forgot').to route_to(controller: 'rockauth/passwords', action: 'forgot', resource_owner_class_name: 'Rockauth::User')
  end

  it 'routes POST /passwords/reset to reset' do
    expect(POST: '/passwords/reset').to route_to(controller: 'rockauth/passwords', action: 'reset', resource_owner_class_name: 'Rockauth::User')
  end
end
