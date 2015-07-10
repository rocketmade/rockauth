require 'spec_helper'
require 'pp'
module Rockauth
  RSpec.describe MeController, type: :controller do
    routes { Engine.routes }

    describe "POST create" do
      let(:client) { create(:client) }
      let(:user_attributes) { attributes_for(:user) }
      let(:authentication_attributes) do
        { client_id: client.id, client_secret: client.secret }
      end

      let(:parameters) do
        { user: user_attributes.merge(authentication: authentication_attributes) }
      end

      it "creates the user" do
        expect do
          post :create, parameters
        end.to change { User.count }.by 1
      end

      context "the client information is incorrect" do
        let(:authentication_attributes) do
          { client_id: "bad", client_secret: "info" }
        end

        it "does not create the user" do
          expect do
            post :create, parameters
          end.not_to change { User.count }
        end

        it "gives meaningful errors" do
          post :create, parameters

        end
      end
    end

    describe "PATCH update" do
    end

    describe "GET show" do
    end
  end
end
