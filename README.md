# Rockauth
##### Because you deserve an auth that :rocket:.

By [Rocketmade](http://rocketmade.com).


## Installation

Rockauth is dependent on Rails version 4.0 or later. To install, add rockauth to your Gemfile:

```ruby
  gem 'rockauth'
```

After you install gems, you can run the installation generator:

```console
  rails generate rockauth:install
```

This generator will install migrations, models, routes, optional gems, translations and an example client into your application.

As a best practice, you should use a different client for each client application for each environment. For instance, iOS, Android and Javascripts would each have distinct client credentials.
You can either alter `config/initializers/rockauth.rb` and load clients however you like, or populate them in `config/rockauth_clients.yml` by using the following command:

```console
  rails generate rockauth:client --client_title "iOS Client" --environment production
```

## Configuration

Configuration can be found in `config/initializers/rockauth.rb`

## Usage

### API Controllers

### API Usage

TODO: describe how to use the API

## Supported Versions

Rails >= 4.0.0

Ruby >= 2.1.0

## Contributing

## License

See MIT-LICENSE