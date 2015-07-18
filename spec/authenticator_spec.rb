require 'spec_helper'

module Rockauth
  describe Authenticator do
    include RSpec::Rails::ControllerExampleGroup

    controller Rockauth::AuthenticationsController do
    end

    describe ".from_request" do
      before :each do
        controller.params.merge! authentication_parameters
      end

      let(:authentication_parameters) do
        {}
      end

      let(:auth_response) { described_class.from_request(request, controller) }

      it "returns a reponse" do
        expect(auth_response).to be_a Authenticator::Response
      end

      context "when missing basic authentication data" do
        let(:authentication_parameters) do
          { authentication: { } }
        end

        it "is not successful" do
          expect(auth_response.success).to be false
        end

        it "provides a meaningful error" do
          expect(auth_response.error).not_to be_blank
          %i(client_id client_secret auth_type).each do |key|
            expect(auth_response.error.validation_errors).to have_key key
            expect(auth_response.error.validation_errors[key]).to include "can't be blank"
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
            auth_response
          end.to change { Rockauth::Authentication.count }.by 1
          expect(auth_response.success).to be true
          expect(auth_response.authentication.resource_owner).to eq user
          expect(auth_response.resource_owner).to eq user
        end

        context "when missing authentication parameters" do
          let(:authentication_parameters) do
            { authentication: { auth_type: 'password' } }
          end

          it "is not successful" do
            expect(auth_response.success).to be false
          end

          it "provides a meaningful error" do
            expect(auth_response.error).not_to be_blank
            expect(auth_response.error.validation_errors).to have_key :username
            expect(auth_response.error.validation_errors).to have_key :password
            expect(auth_response.error.validation_errors[:username].join(' ')).to match /can't be blank/
            expect(auth_response.error.validation_errors[:password].join(' ')).to match /can't be blank/
          end
        end
      end # ~ when authenticating with a password


      context "when authenticating with an assertion", social_auth: true do
        let(:client)   { create(:client) }
        let(:provider) { }
        let(:token)    { 'token' }
        let(:secret)   { 'secret' }
        let(:authentication_parameters) do
          { authentication: { auth_type: 'assertion', provider: provider, provider_token: token, provider_token_secret: secret, client_id: client.id, client_secret: client.secret } }
        end

        # TODO: these errors should reflect how the client passed them up, not our model structure

        context "when missing the provider parameter" do
          it "gives errors for virtual attributes" do
            expect(auth_response.error.validation_errors).not_to be_blank
            expect(auth_response.error.validation_errors).to have_key :provider
            expect(auth_response.error.validation_errors[:provider].join(' ')).to match /can't be blank/
          end
          it "provides a meaningful error" do
            expect(auth_response.error.validation_errors).not_to be_blank
            expect(auth_response.error.validation_errors).to have_key :"provider_authentication.provider"
            expect(auth_response.error.validation_errors[:"provider_authentication.provider"].join(' ')).to match /can't be blank/
          end
        end

        %w(facebook twitter google_plus instagram).each do |network|
          context "facebook" do
            let(:provider) { network }

            it "authenticates the user" do
              expect do
                auth_response
              end.to change { Rockauth::Authentication.count }.by 1
              expect(auth_response.success).to be true
              expect(auth_response.authentication.resource_owner).to be_an_instance_of Rockauth::User
              expect(auth_response.resource_owner).to eq auth_response.authentication.resource_owner
            end

            it "creates the user" do
              expect do
                auth_response
              end.to change { Rockauth::User.count }.by 1
            end
          end
        end
      end # ~ when authenticating with an assertion
    end # ~ .from_request
  end
end
