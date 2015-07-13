require 'webmock/rspec'

RSpec.shared_context :social_auth, social_auth: true do
  let(:provider_user_id) { Faker::Internet.user_name }

  let(:social_user_auth) {
    dbl = double(FbGraph::User)

    # lookup methods
    allow(dbl).to receive(:fetch).and_return dbl
    allow(dbl).to receive(:verify_credentials).and_return dbl
    allow(dbl).to receive(:user).and_return dbl

    # identifier methods
    allow(dbl).to receive(:id).and_return provider_user_id
    allow(dbl).to receive(:identifier).and_return provider_user_id

    dbl
  }

  before :each do
    allow(FbGraph::User).to receive(:me).and_return social_user_auth
    allow(Twitter::REST::Client).to receive(:new).and_return social_user_auth
    allow(GooglePlus::Person).to receive(:get).and_return social_user_auth
    allow(Instagram).to receive(:client).and_return social_user_auth
  end
end
