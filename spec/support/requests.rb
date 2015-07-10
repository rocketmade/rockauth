RSpec.configure do |config|
  config.before :each, type: :controller do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end
end
