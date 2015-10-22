require 'spec_helper'

RSpec.describe Rockauth::User, type: :model do
  subject { build(:user) }
  it { is_expected.to have_many :provider_authentications }
  it { is_expected.to have_many :authentications }
  it { is_expected.to validate_uniqueness_of :email }

  context "email is required" do
    before :each do
      allow(subject).to receive(:email_required?).and_return true
    end

    it { is_expected.to validate_presence_of :email }
    it { is_expected.to     allow_value("test@foo.com", "test.auser@tld.do").for :email }
    it { is_expected.not_to allow_value("test@foo", "test.auser.tld.do").for :email }
  end

  context "password is required" do
    subject { build(:user, password: nil) }

    before :each do
      allow(subject).to receive(:password_required?).and_return true
    end
    it { is_expected.to validate_presence_of :password }
    it { is_expected.to     allow_value("1234567890", "alongasspassword").for :password }
    it { is_expected.not_to allow_value("foo", "123").for :password }
  end

  describe ".with_username" do
    let(:user) { create(:user) }
    it "gets the appropriate user" do
      expect(Rockauth::User.with_username(user.email)).to include user
    end
  end
end
