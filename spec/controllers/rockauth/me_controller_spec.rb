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
      let(:user) { create(:user) }
      let(:authentication) { create(:authentication, user: user) }

      let(:parameters) do
        { user: { password: Faker::Internet.password } }
      end

      context "when unauthenticated" do
        it "raises an error" do
          post :update
          expect(response).not_to be_success
          expect(response.status).to eq 403
          error_body = JSON.parse(response.body)
          expect(error_body["error"]["message"]).to eq I18n.t("rockauth.errors.unauthorized")
        end

        it "does not update the user" do
          expect do
            post :update
          end.not_to change { user.reload.password_digest }
        end
      end

      context "when authenticated" do
        before :each do
          @request.env["HTTP_AUTHORIZATION"] = "bearer #{authentication.token}"
        end
        it "updates the user" do
          expect do
            post :update, parameters
          end.to change { user.reload.password_digest }
        end
      end
    end

    describe "GET show" do
      let(:user) { create(:user) }
      let(:authentication) { create(:authentication, user: user) }

      let(:parameters) do
        { user: { password: Faker::Internet.password } }
      end

      context "when unauthenticated" do
        it "raises an error" do
          get :show
          expect(response).not_to be_success
          expect(response.status).to eq 403
          error_body = JSON.parse(response.body)
          expect(error_body["error"]["message"]).to eq I18n.t("rockauth.errors.unauthorized")
        end
      end

      context "when authenticated" do
        before :each do
          @request.env["HTTP_AUTHORIZATION"] = "bearer #{authentication.token}"
        end
        it "shows the user" do
          get :show
          expect(response).to be_success
          expect(assigns(:user)).to eq user
        end
      end
    end

    describe "DELETE destroy" do
      let(:user) { create(:user) }
      let(:authentication) { create(:authentication, user: user) }

      let(:parameters) do
        { user: { password: Faker::Internet.password } }
      end

      context "when unauthenticated" do
        it "raises an error" do
          delete :destroy
          expect(response).not_to be_success
          expect(response.status).to eq 403
          error_body = JSON.parse(response.body)
          expect(error_body["error"]["message"]).to eq I18n.t("rockauth.errors.unauthorized")
        end

        it "does not delete the user" do
          expect do
            delete :destroy
          end.not_to change { User.count }
        end
      end

      context "when authenticated" do
        before :each do
          @request.env["HTTP_AUTHORIZATION"] = "bearer #{authentication.token}"
        end
        it "destroys the user" do
          expect do
            delete :destroy
          end.to change { User.count }.by(-1)
          expect(response).to be_success
        end
      end
    end
  end
end
