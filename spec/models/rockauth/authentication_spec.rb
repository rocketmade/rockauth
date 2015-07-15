require 'spec_helper'

RSpec.describe Rockauth::Authentication, type: :model do
  subject { build(:password_authentication) }
  it { is_expected.to belong_to :user }

  it { is_expected.to validate_presence_of :auth_type }
  it { is_expected.to validate_presence_of :client_id }
  it { is_expected.to validate_presence_of(:client_secret).on(:create) }

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

  it 'does not store the token in plain text' do
    subject.save
    expect(subject.token).not_to eq subject.encrypted_token
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
end
