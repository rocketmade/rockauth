# Rockauth
##### Because you deserve an auth that :rocket:.

By [Rocketmade](http://rocketmade.com).

Rockauth is an API authentication mechanism for Rails applications which uses [JSON Web Tokens (JWT)](https://en.wikipedia.org/wiki/JSON_Web_Token) as an authentication token.

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

#### Authentication Endpoint

##### Create Authentication

```
POST /api/authentications.json
```

This endpoint is meant to be used to authenticate. However, it has implicit registration behavior when a social network is used to authenticate which is not currently associated with an account.

Request JSON:

```ruby
{
  "authentication": {
    "auth_type":             <string>, # password|assertion                        - Required
    "client_id":             <string>, # -                                         - Required
    "client_secret":         <string>, # -                                         - Required
    "username":              <string>, # -                                         - Required iff auth_type is "password"
    "password":              <string>, # -                                         - Required iff auth_type is "password"
    "client_version":        <string>, # -                                         - Optional
    "device_identifier":     <string>, # -                                         - Optional
    "device_description":    <string>, # -                                         - Optional
    "device_os":             <string>, # -                                         - Optional
    "device_os_version":     <string>, # -                                         - Optional
    "provider_authentication": { # - Required iff auth_type is "assertion"
      "provider":                     <string>, # facebook|google_plus|twitter|instagram - Required iff auth_type is "assertion"
      "provider_access_token":        <string>, # -                                      - Required iff auth_type is "assertion"
      "provider_access_token_secret": <string>  # -                                      - Required iff auth_type is "assertion" and the provider (such as twitter) requires it.
    }
  }
}
```

Successful Response (HTTP Status 200):

```ruby
{
  "authentication": {
    "id":         <integer>,
    "token":      <string>, # JWT
    "expiration": <integer>,
    "resource_owner": {
      "id":    <integer>,
      "email": <string>
    },
    "provider_authentication": {
      "id":       <integer>,
      "provider": <string>
    }
  }
}
```

Example Error Response (HTTP Status 400):

```ruby
{
  "error": {
    "status_code": 400,
    "message": "Authentication failure.",
    "validation_errors": {
      "resource_owner": ["can't be blank", "is not included in the list"],
      "auth_type":      ["can't be blank", "is not included in the list"],
      "client_id":      ["can't be blank", "is invalid"],
      "client_secret":  ["can't be blank", "is invalid"],

      "provider_authentication.provider":              ["is invalid", "is not included in the list"],
      "provider_authentication.provider_access_token": ["is invalid"]
    }
  }
}
```

###### Index Authorizations (List all logged-in devices)

```
GET /api/authorizations.json
```

This endpoint deletes an authorization token, effectively logging the user out. If an ID is provided, that authentication will be deleted. If no id is provided, the current authentication token is deleted.

##### Delete Authorization (Log Out)

```
DELETE /api/authorizations(/:id)?.json
```

This endpoint deletes an authorization token, effectively logging the user out. If an ID is provided, that authentication will be deleted. If no id is provided, the current authentication token is deleted.

##### Create User (Registration)

```
POST /api/me.json
```

This endpoint is meant to be used for registration purposes. Client ID and Secret are still required and an authentication object will be returned which can be used to authenticate future API requests as that user.

Request JSON:

```ruby
{
  "user": {
    "email":    <string>, # - Required if no provider authentications are given
    "password": <string>, # - Required if no provider authentications are given
    "authentication": { # - Required
      "client_id":             <string>, # - Required
      "client_secret":         <string>, # - Required
      "client_version":        <string>, # - Optional
      "device_identifier":     <string>, # - Optional
      "device_description":    <string>, # - Optional
      "device_os":             <string>, # - Optional
      "device_os_version":     <string>  # - Optional
    },
    "provider_authentications": [{ # - Optional
      "provider":                     <string>, # - Required
      "provider_access_token":        <string>, # - Required
      "provider_access_token_secret": <string>  # - Required iff the provider (such as twitter) requires it.
    }] # Any number accepted
  }
}
```

Successful Response (HTTP Status 200):

```ruby
{
  "user": {
    email: <string>,
    "provider_authentications": [...],
    "authentication": {
      "id":         <integer>,
      "token":      <string>, # JWT
      "expiration": <integer>
    }
  }
}
```

Example Error Response (HTTP Status 400):

```ruby
{
  "error": {
    "status_code": 400,
    "message": "User could not be created.",
    "validation_errors": {
      "email":          ["is invalid"]
      "resource_owner": ["can't be blank", "is not included in the list"],
      "auth_type":      ["can't be blank", "is not included in the list"],
      "client_id":      ["can't be blank", "is invalid"],
      "client_secret":  ["can't be blank", "is invalid"],

      "provider_authentication.provider":              ["is invalid", "is not included in the list"],
      "provider_authentication.provider_access_token": ["is invalid"]
    }
  }
}
```

##### Get Current User

```
GET /api/me.json
```

This endpoint is meant to be used to get the currently logged in user. See the JSON response for `POST /api/me.json`

##### Update Current User

```
PUT|PATCH /api/me.json
```

This endpoint is meant to be used to update the currently logged in user. See the JSON request and response data for `POST /api/me.json`.


##### Delete Current User

```
DELETE /api/me.json
```

This endpoint is meant to be used to delete the account and all associated data. If the user cannot be destroyed, expect an `HTTP 409` with error JSON as described above


## Supported Versions

Rails >= 4.0.0

Ruby >= 2.1.0

## Contributing

## License

See MIT-LICENSE
