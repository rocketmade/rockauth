require 'spec_helper'

module Rockauth
  describe Authenticator::Response do
    let!(:client) { create(:client) }
    let(:authentication) { build(:authentication) }
    subject do
      response = Authenticator::Response.new nil
      response.authentication = authentication
      response
    end

    describe '#apply' do
      it "is successful if the authentication saves" do
        expect(authentication).to receive(:save).and_return true
        expect { subject.apply }.to change { subject.success }.to true
      end

      it "is not successful if the authentication saves" do
        expect(authentication).to receive(:save).and_return false
        expect { subject.apply }.to change { subject.success }.to false
      end

      it "sets the resource owner to the authentication resource owner" do
        expect { subject.apply }.to change { subject.resource_owner }.to authentication.resource_owner
      end
    end

    describe '#error' do
      before(:each) do
        subject.apply
      end

      context "when an error is justified" do
        let(:authentication) { build(:invalid_authentication) }
        before :each do
          authentication.valid?
        end

        it "gives a controller error" do
          expect(subject.error).to be_an_instance_of Errors::ControllerError
        end

        it "sets the status code as 400" do
          expect(subject.error.status_code).to eq 400
        end
      end

      context "when an error is not justified" do
        it "gives nil" do
          expect(subject.error).to be_nil
        end
      end
    end

    describe '#render' do
      before(:each) do
        subject.apply
      end

      context "when an error is justified" do
        let(:authentication) { build(:invalid_authentication) }
        before :each do
          authentication.valid?
        end

        it "renders an error code" do
          expect(subject.render[:status]).to eq 400
        end

        it "selects the error serializer" do
          expect(subject.render[:serializer]).to eq Rockauth::ErrorSerializer
        end

        it "selects the error for the json" do
          expect(subject.render[:json]).to eq subject.error
        end
      end

      context "when an error not justified" do
        it "renders a success code" do
          expect(subject.render[:status]).to eq 200
        end

        it "leaves the authorization serializer up to the automatic and model level selection" do
          expect(subject.render).not_to have_key :serializer
        end

        it "selects the error for the json" do
          expect(subject.render[:json]).to eq subject.authentication
        end
      end
    end
  end
end
