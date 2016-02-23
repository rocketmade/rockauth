require 'spec_helper'

describe "me routes" do
  it "routes POST /me to create" do
    expect(POST: "/me").to route_to(controller: "rockauth/me", action: "create", resource_owner_class_name: 'Rockauth::User')
  end

  it "routes PATCH /me to update" do
    expect(PATCH: "/me").to route_to(controller: "rockauth/me", action: "update", resource_owner_class_name: 'Rockauth::User')
  end

  it "routes DELETE /me to destroy" do
    expect(DELETE: "/me").to route_to(controller: "rockauth/me", action: "destroy", resource_owner_class_name: 'Rockauth::User')
  end

  it "routes GET /me to show" do
    expect(GET: "/me").to route_to(controller: "rockauth/me", action: "show", resource_owner_class_name: 'Rockauth::User')
  end
end
