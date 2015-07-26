require 'spec_helper'

describe 'provider authentications routes' do
  routes { Rockauth::Engine.routes }

  it 'routes POST /provider_authentications to create' do
    expect(POST: '/provider_authentications').to route_to(controller: 'rockauth/provider_authentications', action: 'create')
  end

  it 'routes GET /provider_authentications to index' do
    expect(GET: '/provider_authentications').to route_to(controller: 'rockauth/provider_authentications', action: 'index')
  end

  it 'routes PATCH /provider_authentications/3 to destroy' do
    expect(PATCH: '/provider_authentications/3').to route_to(controller: 'rockauth/provider_authentications', action: 'update', id: '3')
  end

  it 'routes DELETE /provider_authentications/1 to destroy' do
    expect(DELETE: '/provider_authentications/1').to route_to(controller: 'rockauth/provider_authentications', action: 'destroy', id: '1')
  end
end
