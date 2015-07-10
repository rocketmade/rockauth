require 'spec_helper'

describe "authentications routes" do
  routes { Rockauth::Engine.routes }

  it "routes POST /authentications to authenticate" do
    expect(POST: "/authentications").to route_to(controller: "rockauth/authentications", action: "authenticate")
  end
end
