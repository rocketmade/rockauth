$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rockauth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rockauth'
  s.version     = Rockauth::VERSION
  s.authors     = ['Daniel Evans']
  s.email       = ['evans.daniel.n@gmail.com']
  s.homepage    = 'TODO'
  s.summary     = 'TODO: Summary of Rockauth.'
  s.description = 'TODO: Description of Rockauth.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency 'rails', '~> 4.2.3'
  s.add_dependency 'rails-api', '~> 0.4.0'
  s.add_dependency 'active_model_serializers', '~> 0.10.0.rc2'
  s.add_dependency 'bcrypt', '~> 3.1.10'
  s.add_dependency 'jwt'

  s.add_development_dependency 'pg'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'shoulda-matchers'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'faker'
end
