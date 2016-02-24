require 'spec_helper'

module Rockauth
  describe PasswordsController do
    let(:parsed_response) { JSON.parse(response.body).with_indifferent_access }

    let(:client) { create(:client) }
    let(:user) { create(:user) }
    let(:password) { Faker::Internet.password }

    describe 'POST forgot' do
      context 'when configured without forgot always successful' do
        before :each do
          @forgot_password_success_config = Rockauth::Configuration.forgot_password_always_successful
          Rockauth::Configuration.forgot_password_always_successful = false
        end

        after :each do
          Rockauth::Configuration.forgot_password_always_successful = @forgot_password_success_config
        end

        it "sends an email to the user with reset instructions" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { ActionMailer::Base.deliveries.length }.by 1
          expect(ActionMailer::Base.deliveries.last.to).to match_array [user.email]
        end

        it "sends an email to the user with the appropriate subject" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { ActionMailer::Base.deliveries.length }.by 1
          expect(ActionMailer::Base.deliveries.last.subject).to eq I18n.t('rockauth.forgot_password_email_subject')
        end

        it "appropriately sets the password reset token for the user" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { user.reload.password_reset_token }
        end

        it "appropriately sets the password reset token expiration for the user" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { user.reload.password_reset_token_expires_at }
        end

        it "notifies the user of success" do
          post :forgot, user: { username: user.email }
          expect(response.status).to eq 200
          expect(parsed_response).to have_key :meta
          expect(parsed_response[:meta]).to have_key :message
        end

        context "when the username is not valid" do

          it "does not send an email" do
            expect do
              post :forgot, user: { username: 'blarg' }
            end.not_to change { ActionMailer::Base.deliveries.length }
          end

          it "informs users of the error" do
            post :forgot, user: { username: 'blarg' }
            expect(response.status).to eq 400
            expect(parsed_response).to have_key :error
            expect(parsed_response[:error]).to have_key :validation_errors
            expect(parsed_response[:error][:validation_errors]).to have_key :username
          end
        end
      end

      context 'when configured with forgot always successful' do
        before :each do
          @forgot_password_success_config = Rockauth::Configuration.forgot_password_always_successful
          Rockauth::Configuration.forgot_password_always_successful = true
        end

        after :each do
          Rockauth::Configuration.forgot_password_always_successful = @forgot_password_success_config
        end

        it "sends an email to the user with reset instructions" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { ActionMailer::Base.deliveries.length }.by 1
          expect(ActionMailer::Base.deliveries.last.to).to match_array [user.email]
        end

        it "appropriately sets the password reset token for the user" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { user.reload.password_reset_token }
        end

        it "appropriately sets the password reset token expiration for the user" do
          expect do
            post :forgot, user: { username: user.email }
          end.to change { user.reload.password_reset_token_expires_at }
        end

        it "notifies the user of success" do
          post :forgot, user: { username: user.email }
          expect(response.status).to eq 200
          expect(parsed_response).to have_key :meta
          expect(parsed_response[:meta]).to have_key :message
        end

        context "when the username is not valid" do

          it "does not send an email" do
            expect do
              post :forgot, user: { username: 'blarg' }
            end.not_to change { ActionMailer::Base.deliveries.length }
          end

          it "does not inform users of the error" do
            post :forgot, user: { username: 'blarg' }
            expect(response.status).to eq 200
            expect(parsed_response).to have_key :meta
            expect(parsed_response[:meta]).to have_key :message
          end
        end
      end
    end

    describe 'POST reset' do
      before :each do
        user.initiate_password_reset
      end

      it "allows updating of the users password" do
        expect do
          post :reset, user: { password_reset_token: user.password_reset_token, password: password }
        end.to change { user.reload.password_digest }
      end

      it "invalidates the password reset token for the user" do
        expect do
          post :reset, user: { password_reset_token: user.password_reset_token, password: password }
        end.to change { user.reload.password_reset_token }.to nil
      end
    end
  end
end
