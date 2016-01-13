require 'spec_helper'

describe "authentications routes" do
  routes { Rockauth::Engine.routes }

  it "routes POST /authentications to authenticate" do
    expect(POST: "/authentications").to route_to(controller: "rockauth/authentications", action: "authenticate", resource_owner_class_name: 'Rockauth::User')
  end

  it "routes GET /authentications to index" do
    expect(GET: "/authentications").to route_to(controller: "rockauth/authentications", action: "index", resource_owner_class_name: 'Rockauth::User')
  end

  it "routes DELETE /authentications to destroy" do
    expect(DELETE: "/authentications").to route_to(controller: "rockauth/authentications", action: "destroy", resource_owner_class_name: 'Rockauth::User')
  end

  it "routes DELETE /authentications/1 to destroy" do
    expect(DELETE: "/authentications").to route_to(controller: "rockauth/authentications", action: "destroy", resource_owner_class_name: 'Rockauth::User')
  end
end
