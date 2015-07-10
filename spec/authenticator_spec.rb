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
        expect(auth_response).to be_a Authenticator::AuthenticationResponse
      end

      context "when missing the authentication parameter" do
        it "is not successful" do
          expect(auth_response.success).to be false
        end
        it "provides a meaningful error" do
          expect(auth_response.errors).not_to be_empty
          expect(auth_response.error_messages).to include I18n.t('rockauth.errors.missing_parameter_error', parameter: :authentication)
        end
      end

      context "when missing basic authentication data" do
        let(:authentication_parameters) do
          { authentication: { foo: 'bar' } }
        end

        it "is not successful" do
          expect(auth_response.success).to be false
        end

        it "provides a meaningful error" do
          expect(auth_response.errors).not_to be_empty
          expect(auth_response.error_messages).to include I18n.t('rockauth.errors.missing_parameter_error', parameter: :client_id)
          expect(auth_response.error_messages).to include I18n.t('rockauth.errors.missing_parameter_error', parameter: :client_secret)
          expect(auth_response.error_messages).to include I18n.t('rockauth.errors.missing_parameter_error', parameter: :auth_type)
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
          expect(auth_response.authentication.user).to eq user
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
            expect(auth_response.errors).not_to be_empty
            expect(auth_response.error_messages).to include I18n.t('rockauth.errors.missing_parameter_error', parameter: :username)
            expect(auth_response.error_messages).to include I18n.t('rockauth.errors.missing_parameter_error', parameter: :password)
          end
        end
      end # ~ when authenticating with a password


      context "when authenticating with an assertion", pending: "Not Implemented" do
        context "facebook" do

        end

        context "twitter" do
        end

        context "instagram" do
        end
      end # ~ when authenticating with an assertion

    end # ~ .from_request
  end
end
