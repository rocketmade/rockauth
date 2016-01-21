require 'spec_helper'

module Rockauth
  describe Controllers::Authentication do
    controller(ActionController::API) do
      before_filter :authenticate_resource_owner!, except: [:show]

      def index
        render text: current_resource_owner.to_s
      end

      def show
        current_resource_owner.try(:foo)
        current_resource_owner.try(:bar)
        render json: { resource_owner_id: current_resource_owner.try(:id) }
      end

      def resource_owner_class
        Rockauth::User
      end
    end

    context "logged out" do
      it "caches authentication failure" do
        expect(Authenticator).to receive(:verified_authentication_for_request).once

        routes.draw { get "show", to: "anonymous#show" }
        get :show
      end
    end

    context "a valid authentication", authenticated_request: true do
      it "completes appropriately" do
        get :index
        expect(response).to be_success
      end
    end

    context "an expired token", authenticated_request: true do
      let(:given_auth) { create(:authentication, expiration: (Time.now - 60).to_i) }
      it "denies access" do
        get :index
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
    end

    context "a corrupted token", authenticated_request: true do
      let(:given_auth) { create(:authentication, token: 'liesanddeciet') }
      it "denies access" do
        get :index
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
    end

    context "a forged token", authenticated_request: true do
      let(:iat) { Time.now.to_i }
      let(:exp) { (Time.now + 1.year).to_i }
      let(:given_auth) do
        create(:authentication, expiration: exp, issued_at: iat, token_id: 'notveritas', token: JWT.encode({ exp: exp, iat: iat, sub_id: create(:user).id, jti: 'veritas' }, ''))
      end
      it "denies access" do
        get :index
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
    end

    context "a differently forged token", authenticated_request: true do
      let(:iat) { Time.now.to_i }
      let(:exp) { (Time.now + 1.year).to_i }

      let(:token) do
        t = JWT.encode({ exp: exp, iat: iat, sub_id: create(:user).id, jti: 'notveritas' }, '').split('.')
        t[1] = Base64.encode64({ exp: exp, iat: iat, sub_id: create(:user).id, jti: 'veritas' }.to_json)
        t.join('.')
      end
      let(:other_auth) do
        create(:authentication, expiration: exp, issued_at: iat, token_id: 'veritas')
      end
      let(:given_auth) do
        create(:authentication, token_id: 'notveritas', token: token)
      end
      it "denies access" do
        get :index
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
    end

    context "a token with the wrong secret", authenticated_request: true do
      let(:iat) { Time.now.to_i }
      let(:exp) { (Time.now + 1.year).to_i }
      let(:given_auth) do
        create(:authentication, expiration: exp, issued_at: iat, token_id: 'veritas', token: JWT.encode({ exp: exp, iat: iat, sub_id: create(:user).id, jti: 'veritas' }, 'wrong'))
      end
      it "denies access" do
        get :index
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
    end
  end
end
