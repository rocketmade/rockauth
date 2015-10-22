require 'faker'
I18n.reload! # wat
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
