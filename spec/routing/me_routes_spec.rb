require 'spec_helper'

describe "me routes" do
  routes { Rockauth::Engine.routes }

  it "routes POST /me to create" do
    expect(POST: "/me").to route_to(controller: "rockauth/me", action: "create")
  end

  it "routes PATCH /me to update" do
    expect(PATCH: "/me").to route_to(controller: "rockauth/me", action: "update")
  end

  it "routes DELETE /me to destroy" do
    expect(DELETE: "/me").to route_to(controller: "rockauth/me", action: "destroy")
  end

  it "routes GET /me to show" do
    expect(GET: "/me").to route_to(controller: "rockauth/me", action: "show")
  end
end
