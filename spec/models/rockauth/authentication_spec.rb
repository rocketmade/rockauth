require 'spec_helper'

RSpec.describe Rockauth::Authentication, type: :model do
  subject { build(:password_authentication) }
  it { is_expected.to belong_to :resource_owner }

  it { is_expected.to validate_presence_of :auth_type }
  it { is_expected.to validate_presence_of :client_id }
  it { is_expected.to validate_presence_of(:client_secret).on(:create) }
  it { is_expected.to allow_value(*%w(password assertion registration)).for(:auth_type) }
  it { is_expected.not_to allow_value(*%w(passwords assertionish registrationy)).for(:auth_type) }

  it 'validates the client id' do
    subject.client_id = 'wrong'
    expect(subject.valid?).to be false
    expect(subject.errors[:client_id]).to include I18n.t('errors.messages.invalid')
  end

  it 'validates the client secret' do
    subject.client_secret = 'wrong'
    expect(subject.valid?).to be false
    expect(subject.errors[:client_secret]).to include I18n.t('errors.messages.invalid')
  end

  it 'does not store the token_id in plain text' do
    subject.save
    expect(subject.token_id).not_to eq subject.hashed_token_id
  end

  it 'does not store the token retrievably' do
    subject.save
    loaded = described_class.find(subject.id)
    expect(loaded.token).to be nil
  end

  context 'when it is a password authentication' do
    it { is_expected.to validate_presence_of(:username).on(:create) }
    it { is_expected.to validate_presence_of(:password).on(:create) }
    it 'validates that the password is correct' do
      subject.password = 'wrong'
      expect(subject.valid?).to be false
      expect(subject.errors[:password]).to include I18n.t('errors.messages.invalid')
    end
  end

  describe "creation" do
    it "generates a token" do
      expect do
        subject.save!
      end.to change { subject.token }
    end

    it "sets the issued at" do
      Timecop.freeze do
        expect do
          subject.save!
        end.to change { subject.issued_at }.to Time.now.to_i
      end
    end

    it "sets the expiration" do
      Timecop.freeze do
        expect do
          subject.save!
        end.to change { subject.expiration }.to (Time.now + Rockauth::Configuration.token_time_to_live).to_i
      end
    end

  end
end
