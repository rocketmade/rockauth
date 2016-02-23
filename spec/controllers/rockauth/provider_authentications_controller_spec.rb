require 'spec_helper'

module Rockauth
  RSpec.describe ProviderAuthenticationsController, type: :controller, social_auth: true do
    describe "GET index" do
      context "when unauthenticated" do
        it "denies access" do
          get :index
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end
      end

      context "when authenticated", authenticated_request: true do
        let!(:user_authentications) { create_list(:predefined_provider_authentication, 3, resource_owner: given_auth.resource_owner) }
        let!(:other_authentications) { create_list(:predefined_provider_authentication, 3) }
        it "gives only the authenticated resource owners provider authentications" do
          get :index
          expect(assigns(:provider_authentications)).to match_array user_authentications
        end

        it "does not give the access token in the response" do
          get :index
          expect(response.body).not_to match /access_token/
        end
      end
    end

    describe "GET show" do
      context "when unauthenticated" do
        it "denies access" do
          get :show, id: create(:predefined_provider_authentication).id
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end
      end

      context "when authenticated", authenticated_request: true do
        let!(:provider_authentication) { create(:predefined_provider_authentication, resource_owner: given_auth.resource_owner) }
        it "does not give the access token in the response" do
          get :show, id: provider_authentication.id
          expect(response.body).not_to match /access_token/
        end

        it "does not give other users provider authentications" do
          expect {
            get :show, id: create(:predefined_provider_authentication).id
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    describe "POST create" do
      context "when unauthenticated" do
        it "denies access" do
          post :create, provider_authentication: {}
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end
      end

      context "when authenticated", authenticated_request: true do
        let(:provider_authentication_attributes) do
          {
            provider: 'facebook',
            provider_access_token: 'foobarbinbaz'
          }
        end

        it "creates the authentication" do
          expect {
            post :create, provider_authentication: provider_authentication_attributes
          }.to change { ProviderAuthentication.where(resource_owner: given_auth.resource_owner).count }
          expect(response).to be_success
        end

        context "given a provider user id of another existing record" do
          let(:provider) { 'facebook' }
          let(:provider_user_id) { 1 }

          before do
            create(:predefined_provider_authentication, provider: provider, provider_user_id: provider_user_id)
          end

          it "gives rational errors" do
            expect {
              post :create, provider_authentication: { provider: provider, provider_access_token: 'foobarbinbaz' }
            }.not_to change { ProviderAuthentication.where(resource_owner: given_auth.resource_owner).count }
            expect(response).not_to be_success
            json = JSON.parse(response.body)
            expect(json).to have_key 'error'
            expect(json['error']['message']).to match /provider authentication could not be created/i
          end
        end
      end
    end

    describe "PATCH update" do
      context "when unauthenticated" do
        it "denies access" do
          patch :update, id: create(:provider_authentication).id, provider_authentication: {}
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end
      end

      context "when authenticated", authenticated_request: true do
        let!(:provider_authentication) { create(:provider_authentication, resource_owner: given_auth.resource_owner) }
        it "updates the provider authentication" do
          expect {
            patch :update, id: provider_authentication.id, provider_authentication: { provider_access_token: 'blarg' }
          }.to change { provider_authentication.reload.provider_access_token }.to 'blarg'
        end

        it "does not allow updating of another resource owners provider authentications" do
          expect {
            patch :update, id: create(:predefined_provider_authentication).id, provider_authentication: { provider_access_token: 'blarg' }
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    describe "DELETE destroy" do
      context "when unauthenticated" do
        it "denies access" do
          delete :destroy, id: create(:provider_authentication).id, provider_authentication: {}
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end
      end

      context "when authenticated", authenticated_request: true do
        let!(:provider_authentication) { create(:provider_authentication, resource_owner: given_auth.resource_owner) }
        it "delete the provider authentication" do
          create(:authentication, resource_owner: given_auth.resource_owner, provider_authentication: provider_authentication)
          expect {
            delete :destroy, id: provider_authentication.id, provider_authentication: { provider_access_token: 'blarg' }
          }.to change { given_auth.resource_owner.provider_authentications.where(id: provider_authentication.id).count }.from(1).to(0)
        end

        it "does not allow updating of another resource owners provider authentications" do
          expect {
            delete :destroy, id: create(:predefined_provider_authentication).id, provider_authentication: { provider_access_token: 'blarg' }
          }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end
  end
end
