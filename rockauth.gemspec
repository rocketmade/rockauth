$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rockauth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rockauth'
  s.version     = Rockauth::VERSION
  s.authors     = ['Daniel Evans']
  s.email       = ['evans.daniel.n@gmail.com']
  s.homepage    = 'https://github.com/rocketmade/rockauth'
  s.summary     = 'An opinionated API Token Authentication mechanism.'
  s.description = 'An opinionated API Token Authentication mechanism.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '>= 4.2.0'
  s.add_dependency 'rails-api', '>= 0.4.0'
  s.add_dependency 'active_model_serializers'
  s.add_dependency 'bcrypt', '>= 3.1.10'
  s.add_dependency 'jwt'
  s.add_dependency 'hooks'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec-mocks', '3.3.2' # 3.4.1 caused stack too deep errors
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'shoulda-matchers', '~> 2.8.0'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker'
  s.add_development_dependency 'twitter'
  s.add_development_dependency 'fb_graph2'
  s.add_development_dependency 'instagram'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'activeadmin'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'warden'
  s.add_development_dependency 'useragent'
end
