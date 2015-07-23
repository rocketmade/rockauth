require 'spec_helper'

module Rockauth
  describe Controllers::Authentication do
    controller(ActionController::API) do
      before_filter :authenticate_resource_owner!
      def index
        render text: current_resource_owner.to_s
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
