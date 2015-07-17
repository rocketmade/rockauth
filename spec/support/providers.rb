require 'webmock/rspec'

RSpec.shared_context :social_auth, social_auth: true do
  let(:provider_user_id) { Faker::Internet.user_name }

  let(:social_user_auth) {
    dbl = double(FbGraph2::User)

    allow(dbl).to receive(:id).and_return provider_user_id
    allow(dbl).to receive(:identifier).and_return provider_user_id

    dbl.as_null_object
  }

  before :each do
    allow(FbGraph2::User).to receive(:me).and_return social_user_auth
    allow(Twitter::REST::Client).to receive(:new).and_return social_user_auth
    allow(GooglePlus::Person).to receive(:get).and_return social_user_auth
    allow(Instagram).to receive(:client).and_return social_user_auth
  end
end
