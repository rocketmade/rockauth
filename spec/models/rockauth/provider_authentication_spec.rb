require 'spec_helper'

RSpec.describe Rockauth::ProviderAuthentication, type: :model do
  subject { build(:provider_authentication) }

  it { is_expected.to belong_to :user }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :provider }
  it { is_expected.to validate_presence_of :provider_user_id }
  it { is_expected.to validate_presence_of :provider_access_token }
  it { is_expected.to validate_presence_of :provider_key }
  it { is_expected.to validate_uniqueness_of(:provider_user_id).scoped_to(:provider) }

end
