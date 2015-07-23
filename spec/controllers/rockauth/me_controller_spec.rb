require 'spec_helper'

module Rockauth
  RSpec.describe MeController, type: :controller do
    routes { Engine.routes }
    let(:parsed_response) { JSON.parse(response.body).with_indifferent_access }

    describe 'POST create' do
      let(:client) { create(:client) }
      let(:user_attributes) { attributes_for(:user) }
      let(:authentication_attributes) do
        { client_id: client.id, client_secret: client.secret }
      end

      let(:parameters) do
        { user: user_attributes.merge(authentication: authentication_attributes) }
      end

      it 'creates the user' do
        expect do
          post :create, parameters
        end.to change { User.count }.by 1
      end

      it 'includes the authentication token_id in the response' do
        post :create, parameters
        expect(parsed_response[:user]).to have_key :authentication
        expect(parsed_response[:user][:authentication]).to have_key :token_id
      end

      context "detailed client information is provided" do
        let(:authentication_attributes) do
          {
            client_id: client.id,
            client_secret: client.secret,
            client_version: '1.2.2',
            device_identifier: 'foo_device',
            device_os: 'iOS - super touchy sexy edition',
            device_os_version: '30.0.1.2-patch231',
            device_description: 'Rocketmade Spare iPhablet'
          }
        end

        it "records detailed information to the authentication" do
          post :create, parameters
          auth = assigns(:user).authentications.first
          %i(client_version device_identifier device_os device_os_version device_description).each do |key|
            expect(auth.public_send(key)).to eq authentication_attributes[key]
          end
        end
      end


      context 'the client information is incorrect' do
        let(:authentication_attributes) do
          { client_id: 'bad', client_secret: 'info' }
        end

        it 'does not create the user' do
          expect do
            post :create, parameters
          end.not_to change { User.count }
        end

        it 'gives meaningful errors' do
          post :create, parameters
          expect(parsed_response[:error][:message]).to match /could not be/
        end
      end

      context 'the username and password are not present' do
        let(:user_attributes) { {} }

        it 'does not create the user' do
          expect do
            post :create, parameters
          end.not_to change { User.count }
        end

        it 'gives meaningful errors' do
          post :create, parameters
          expect(response).not_to be_success
          expect(parsed_response[:error][:message]).to match /could not be/
          expect(parsed_response[:error][:validation_errors]).to have_key :email
          expect(parsed_response[:error][:validation_errors]).to have_key :password
        end

        context 'when provider authentication data is given', social_auth: true do
          let(:user_attributes) { { provider_authentications: [{ provider: 'facebook', provider_access_token: 'foo' }]} }

          it 'creates the user' do
            expect do
              post :create, parameters
            end.to change { User.count }.by 1
          end

        end
      end
    end

    describe 'PATCH update' do
      let(:parameters) do
        { user: { password: 'adifferentpassword123' } }
      end

      context 'when unauthenticated' do
        it 'raises an error' do
          post :update
          expect(response).not_to be_success
          expect(response.status).to eq 401
          error_body = JSON.parse(response.body)
          expect(error_body['error']['message']).to eq I18n.t('rockauth.errors.unauthorized')
        end
      end

      context 'when authenticated', authenticated_request: true do
        it 'updates the user' do
          expect do
            patch :update, parameters
          end.to change { given_auth.resource_owner.reload.password_digest }
          expect(response).to be_success
        end
      end
    end

    describe 'GET show' do
      let(:parameters) do
        { user: { password: Faker::Internet.password } }
      end

      context 'when unauthenticated' do
        it 'raises an error' do
          get :show
          expect(response).not_to be_success
          expect(response.status).to eq 401
          error_body = JSON.parse(response.body)
          expect(error_body['error']['message']).to eq I18n.t('rockauth.errors.unauthorized')
        end
      end

      context 'when authenticated', authenticated_request: true do
        it 'shows the user' do
          get :show
          expect(response).to be_success
          expect(assigns(:user)).to eq given_auth.resource_owner
        end
      end
    end

    describe 'DELETE destroy' do
      let(:user) { create(:user) }
      let(:authentication) { create(:authentication, resource_owner: user) }

      let(:parameters) do
        { user: { password: Faker::Internet.password } }
      end

      context 'when unauthenticated' do
        it 'raises an error' do
          delete :destroy
          expect(response).not_to be_success
          expect(response.status).to eq 401
          error_body = JSON.parse(response.body)
          expect(error_body['error']['message']).to eq I18n.t('rockauth.errors.unauthorized')
        end

        it 'does not delete the user' do
          expect do
            delete :destroy
          end.not_to change { User.count }
        end
      end

      context 'when authenticated', authenticated_request: true do
        it 'destroys the user' do
          expect do
            delete :destroy
          end.to change { User.count }.by(-1)
          expect(response).to be_success
        end

        context "when the user fails to destroy" do
          it 'returns appropriate errors' do
            allow_any_instance_of(User).to receive(:destroy).and_return false
            delete :destroy
            expect(response).not_to be_success
            expect(response.status).to eq 409
          end
        end
      end
    end
  end
end
