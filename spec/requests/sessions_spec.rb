require 'spec_helper'

module Rockauth
  RSpec.describe 'Session Creation', type: :request do
    include ::Warden::Test::Helpers
    after { ::Warden.test_reset! }

    let(:class_name_params) do
      { resource_owner_class_name: "Rockauth::User" }
    end

    describe 'POST create' do
      let(:authentication_parameters) do
        {}
      end

      let(:parsed_response) { JSON.parse(response.body) }

      before(:each) do
        Rockauth::Configuration.session_client = create(:client)
      end

      context 'when posting an auth token for an existing authentication' do
        let(:authentication_parameters) do
          { token: authentication.token }
        end

        let!(:user) { create(:user) }
        let(:client) { create(:client) }

        let!(:authentication) do
          create(:password_authentication, resource_owner: user, client: client)
        end

        it "authenticates the user" do
          expect do
            post '/sessions', authentication_parameters
          end.not_to change { Rockauth::Authentication.count }
          expect(response).to redirect_to '/'
          expect(request.env['warden'].user(:user)).to be_a Rockauth::Authentication
          expect(request.env['warden'].user(:user).resource_owner).to eq user
        end
      end

      context 'when missing basic authentication data' do
        let(:authentication_parameters) do
          { authentication: { username: 'foo', password: 'bar' } }
        end

        it 'displays the form with the username populated', pending: true do
          post '/sessions', class_name_params.merge(authentication_parameters)
          expect(response.body).to match /value="foo"/
        end
      end

      context "when authenticating with a password" do
        let!(:user) { create(:user) }
        let(:client) { create(:client) }

        let(:authentication_parameters) do
          { authentication: { username: user.email, password: user.password } }
        end

        it "authenticates the user" do
          expect do
            post '/sessions', authentication_parameters
          end.to change { Rockauth::Authentication.count }.by 1
          expect(response).to redirect_to '/'
          expect(request.env['warden'].user(:user)).to be_a Rockauth::Authentication
          expect(request.env['warden'].user(:user).resource_owner).to eq user
        end
      end

    end

    describe "DELETE destroy" do
      it 'requires authentication' do
        expect {
          delete '/sessions', class_name_params
        }.not_to change { Rockauth::Authentication.count }
        expect(response).not_to be_success
        expect(response).to be
      end

      context "when authenticated" do
        let(:authentication) { create(:authentication) }
        before(:each) do
          login_as authentication, scope: :user
        end

        context "with no id" do
          it "deletes the current authentication" do
            expect {
              delete '/sessions', class_name_params
            }.to change { Authentication.where(id: authentication.id).count }.from(1).to(0)
          end

          context "the configured sign out method is used to sign out" do
            before :each do
              @original_method = Rockauth::Configuration.signout_method
              Rockauth::Configuration.signout_method = :destroy!
            end

            after :each do
              Rockauth::Configuration.signout_method = @original_method
            end

            it "uses the configured method for destruction" do
              expect_any_instance_of(Authentication).to receive(:destroy!).and_return true
              delete '/sessions', class_name_params
            end
          end
        end
      end
    end
  end
end
