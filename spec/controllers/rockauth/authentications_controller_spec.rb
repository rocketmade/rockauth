require 'spec_helper'

module Rockauth
  RSpec.describe AuthenticationsController, type: :controller do
    controller do
    end
    routes { Engine.routes }

    describe 'GET index' do
      it 'requires authentication' do
        get :index
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
      context "when authenticated" do
        let(:authentication) { create(:authentication) }
        before :each do
          @request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication.jwt}"
        end

        it "returns all authorizations for the current user" do
          other_auths = create_list(:authentication, 3, resource_owner: authentication.resource_owner)
          get :index
          expect(assigns(:authentications)).to match_array (other_auths + [authentication])
        end

        it "does not return other users authentications" do
          other_auth = create(:authentication)
          get :index
          expect(assigns(:authentications)).not_to include other_auth
        end
      end
    end

    describe 'POST authenticate' do
      let(:authentication_parameters) do
        {}
      end

      let!(:client) { create(:client) }
      let(:parsed_response) { JSON.parse(response.body) }

      context 'when missing basic authentication data' do
        let(:authentication_parameters) do
          { authentication: { } }
        end

        it 'is not successful' do
          post :authenticate, authentication_parameters
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        it 'provides a meaningful error' do
          post :authenticate, authentication_parameters
          expect(parsed_response['error']['validation_errors']).not_to be_blank
          %w(client_id client_secret auth_type).each do |key|
            expect(parsed_response['error']['validation_errors']).to have_key key
            expect(parsed_response['error']['validation_errors'][key]).to include 'can\'t be blank'
          end
        end

      end

      context "when authenticating with a password" do
        let!(:user) { create(:user) }
        let(:client) { create(:client) }

        let(:authentication_parameters) do
          { authentication: { auth_type: 'password', client_id: client.id, client_secret: client.secret, username: user.email, password: user.password } }
        end

        it "authenticates the user" do
          expect do
            post :authenticate, authentication_parameters
          end.to change { Rockauth::Authentication.count }.by 1
          expect(response).to be_success
          expect(assigns(:auth_response).resource_owner).to eq user
        end

        context "detailed client information is provided" do
          let(:authentication_parameters) do
            {
              authentication: {
                auth_type: 'password',
                client_id: client.id,
                client_secret: client.secret,
                username: user.email,
                password: user.password,
                client_version: '1.2.2',
                device_identifier: 'foo_device',
                device_os: 'iOS - super touchy sexy edition',
                device_os_version: '30.0.1.2-patch231',
                device_description: 'Rocketmade Spare iPhablet'
              }
            }
          end

          it "records detailed information to the authentication" do
            post :authenticate, authentication_parameters
            auth = assigns(:auth_response).authentication
            %i(client_version device_identifier device_os device_os_version device_description).each do |key|
              expect(auth.public_send(key)).to eq authentication_parameters[:authentication][key]
            end
          end
        end

        it 'includes the authentication token_id in the response' do
          post :authenticate, authentication_parameters
          expect(parsed_response['authentication']).to have_key 'token_id'
        end

        it 'includes the authentication jwt in the response' do
          post :authenticate, authentication_parameters
          expect(parsed_response['authentication']).to have_key 'jwt'
        end

        it 'includes the authentication token_id in the response' do
          post :authenticate, authentication_parameters
          expect(parsed_response['authentication']).to have_key 'resource_owner'
        end

        context "when missing authentication parameters" do
          let(:authentication_parameters) do
            { authentication: { auth_type: 'password' } }
          end

          it "is not successful" do
            post :authenticate, authentication_parameters
            expect(response).not_to be_success
            expect(response.status).to eq 400
          end

          it "provides a meaningful error" do
            post :authenticate, authentication_parameters
            expect(parsed_response['error']['validation_errors']).not_to be_blank
            expect(parsed_response['error']['validation_errors']).to have_key 'username'
            expect(parsed_response['error']['validation_errors']).to have_key 'password'
            expect(parsed_response['error']['validation_errors']['username'].join(' ')).to match /can't be blank/
            expect(parsed_response['error']['validation_errors']['password'].join(' ')).to match /can't be blank/
          end
        end

        context "when the client_id is incorrect" do

          let(:authentication_parameters) do
            { authentication: { auth_type: 'password', client_id: 'foo', client_secret: client.secret, username: user.email, password: user.password } }
          end

          it 'provides a meaningful error' do
            post :authenticate, authentication_parameters
            expect(parsed_response['error']['validation_errors']).not_to be_blank
            expect(parsed_response['error']['validation_errors']).to have_key 'client_id'
          end
        end

        context "when the client_secret is incorrect" do
          let(:authentication_parameters) do
            { authentication: { auth_type: 'password', client_id: client.id, client_secret: 'client.secret', username: user.email, password: user.password } }
          end

          it 'provides a meaningful error' do
            post :authenticate, authentication_parameters
            expect(parsed_response['error']['validation_errors']).not_to be_blank
            expect(parsed_response['error']['validation_errors']).to have_key 'client_secret'
          end
        end
      end

      context "when authenticating with an assertion", social_auth: true do
        let!(:user) { create(:user) }
        let(:client) { create(:client) }
        let(:provider) { }
        let(:provider_authentication) { create(:provider_authentication, resource_owner: user, provider: provider, provider_user_id: provider_user_id) }

        let(:authentication_parameters) do
          { authentication: { auth_type: 'assertion', client_id: client.id, client_secret: client.secret, provider_authentication: { provider: provider, provider_access_token: 'foo', provider_access_token_secret: 'bar' } } }
        end

        context "non-existant provider" do
          let(:provider) { 'narcissists_book' }

          it "is not successful" do
            post :authenticate, authentication_parameters
            expect(response).not_to be_success
            expect(response.status).to eq 400
          end
        end

        %w(facebook twitter google_plus instagram).each do |prov|
          context prov do
            let(:provider) { prov }

            it "creates a new user and authenticates" do
              expect {
                post :authenticate, authentication_parameters
              }.to change { User.count }.by 1
              expect(response).to be_success
              expect(parsed_response['authentication']['resource_owner']['id']).to eq User.last.id
              expect(parsed_response['authentication']['provider_authentication']['provider']).to eq provider
            end

            it "authenticates with the existing user" do
              provider_authentication
              expect {
                post :authenticate, authentication_parameters
              }.not_to change { [User.count, ProviderAuthentication.count] }
              expect(response).to be_success
              expect(parsed_response['authentication']['resource_owner']['id']).to eq user.id
              expect(parsed_response['authentication']['provider_authentication']['id']).to eq provider_authentication.id
            end

            context "provider authentication fails" do
              let(:provider_user_id) { nil }
              it "does not authenticate" do
                expect {
                  post :authenticate, authentication_parameters
                }.not_to change { Authentication.count }
                expect(response).not_to be_success
              end
            end
          end
        end

      end
    end

    describe "DELETE destroy" do
      it 'requires authentication' do
        delete :destroy
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end

      context "when authenticated" do
        let(:authentication) { create(:authentication) }
        before :each do
          @request.env['HTTP_AUTHORIZATION'] = "Bearer #{authentication.jwt}"
        end

        context "with no id" do
          it "deletes the current authentication" do
            expect {
              delete :destroy
            }.to change { Authentication.where(id: authentication.id).count }.from(1).to(0)
          end
        end

        context "with an id" do
          it "deletes the given authentication" do
            auth = create(:authentication, resource_owner: authentication.resource_owner)
            expect {
              delete :destroy, id: auth.id
            }.to change { Authentication.where(id: auth.id).count }.from(1).to(0)
          end
        end

        context "with another resource owners authentication id" do
          it "gives not found" do
            auth = create(:authentication)
            expect {
              delete :destroy, id: auth.id
            }.to raise_error ActiveRecord::RecordNotFound
            expect(Authentication.where(id: auth.id).count).to eq 1
          end
        end

      end
    end
  end
end
