require 'spec_helper'

RSpec.describe Rockauth::ProviderAuthentication, type: :model, social_auth: true do
  subject { build(:provider_authentication) }

  it { is_expected.to belong_to :user }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :provider }
  it { is_expected.to validate_presence_of :provider_access_token }

  %w(facebook google_plus instagram twitter).each do |key|
    context "when the provider is #{key}" do
      subject { build(:provider_authentication, provider: key) }
      it "sets the provider user id" do
        expect do
          subject.save
        end.to change { subject.provider_user_id }.to provider_user_id
      end
    end
  end
end
