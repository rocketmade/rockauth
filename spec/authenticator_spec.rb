require 'spec_helper'

module Rockauth
  describe Authenticator do
    include RSpec::Rails::ControllerExampleGroup

    controller Rockauth::AuthenticationsController do
    end

    describe ".from_request" do
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
        before :each do
          controller.params[:authentication] = {
            foo: :bar
          }
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
    end
  end
end
