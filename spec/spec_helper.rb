
ENV['RAILS_ENV'] ||= 'test'

unless ENV["SIMPLECOV"] == 'false'
  require 'simplecov'
  SimpleCov.start 'rails' do
    add_filter "/spec"
  end
end
require 'database_cleaner'
require File.expand_path('../dummy/config/environment', __FILE__)

abort("The Rails environment is not running in test mode!") unless Rails.env.test?
require 'rspec/rails'
require 'shoulda/matchers'
require 'factory_girl_rails'
require 'webmock'
require 'timecop'

Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each { |f| require f }
ActiveRecord::Migration.maintain_test_schema!
ActiveRecord::Base.include_root_in_json = true
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:suite) { DatabaseCleaner.clean_with :truncation }
  config.after(:suite)  { DatabaseCleaner.clean_with :truncation }
end
