require 'spec_helper'

module Rockauth
  describe Warden do
    it "adds warden to the middleware when included" do
      expect(Rails.application.middleware.middlewares.map { |m| m.klass.to_s }).to include 'Warden::Manager'
    end

    it "adds the rockauth password strategy to Warden" do
      expect(::Warden::Strategies[:rockauth_password]).to eq Rockauth::Warden::PasswordStrategy
    end

    it "adds the rockauth token strategy to Warden" do
      expect(::Warden::Strategies[:rockauth_token]).to eq Rockauth::Warden::TokenStrategy
    end
  end
end
