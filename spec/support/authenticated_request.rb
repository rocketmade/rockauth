shared_context :authenticated_request, authenticated_request: true do
  let(:given_auth) { create(:authentication) }

  before(:each) do
    @request.env['HTTP_AUTHORIZATION'] = "Bearer #{given_auth.token}"
  end
end
