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
  rails generate rockauth:client "iOS Client" --environment production
```

## Configuration

Configuration can be found in `config/initializers/rockauth.rb`

## Usage

### API Controllers

If your controllers inherit from `ActionController::API` you can simply start using the helpers. If they don't, you will need to `include Rockauth::Controllers::Authentication` inside your base controller.

Once you have the module included, you can use the following helpers:

 - `authenticate_resource_owner!` is meant to be a before_filter which requires authentication.
 - `current_resource_owner` gives the currently logged in user, nil if none
 - `current_authentication` gives the current authentication

The `render_error` and `render_unauthorized` helpers are also included and used to render the error response, thus providing a point of customization for errors.

#### Example

```ruby
class SimpleController < ActionController::API
  before_filter :authenticate_resource_owner!, except: [:insecure]

  def insecure
    render text: "This was insecurely rendered. logged in resource owner: #{current_resource_owner.try(:id)}"
  end

  def authenticated
    render text: "This was authenticated. logged in resource owner: #{current_resource_owner.id}"
  end
end
```


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
    "id":                  <integer>,
    "token":               <string>, # JWT
    "expiration":          <integer>,
    "resource_owner_type": <string>,
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

Example CURL:
```
curl localhost:3000/api/authentications.json -H "Content-Type: application/json" -d '{ "authentication": { "auth_type": "password", "client_id": "McTmY25bDvQ-ypVbwRDmeg", "client_secret": "nSjjCdegeujKvB0CHE2dPLWxg4NZCxoeokcoQj39Vhw", "username": "test@example.com", "password": "testing123" } }'
```

Response:

```
{"authentication":{"id":1,"token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE0NjkwOTAyOTYsInN1YiI6MSwic3ViX3R5cGUiOiJSb2NrYXV0aDo6VXNlciJ9.gNvFfI-JapDgmSUhAcnui63fOEVz9EnsnzLxqjZW-WQ","expiration":1469090296,"client_version":null,"device_identifier":null,"device_os":null,"device_os_version":null,"device_description":null,"user":{"id":1,"email":"test@example.com","provider_authentications":[]},"provider_authentication":null}}
```

###### Index Authentications (List all logged-in devices)

```
GET /api/authentications.json
```

##### Delete Authentication (Log Out)

```
DELETE /api/authentications(/:id)?.json
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
    "first_name": <string>, # - Optional
    "last_name": <string>, # - Optional
    "email":      <string>, # - Required if no provider authentications are given
    "password":   <string>, # - Required if no provider authentications are given
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



##### Create Provider Authentication (Link to a social network)

```
POST /api/provider_authentications.json
```

This endpoint is meant to be used for associating new social networks to an existing account.

Request JSON:

```ruby
{
  "provider_authentication": {
    "provider":                     <string>, # facebook|google_plus|twitter|instagram - Required
    "provider_access_token":        <string>, #                                        - Required
    "provider_access_token_secret": <string>, #                                        - Required depending on the social network (Twitter)
  }
}
```

Successful Response (HTTP Status 200):

```ruby
{
  "provider_authentication": {
    id:               <integer>,
    provider:         <string>,
    provider_user_id: <string>
  }
}
```

Example Error Response (HTTP Status 400):

```ruby
{
  "error": {
    "status_code": 400,
    "message": "Provider Authentication could not be created.",
    "validation_errors": {
      "provider":              ["can't be blank", "is not included in the list"],
      "provider_access_token": ["can't be blank", "is invalid"],
      "provider_user_id":      ["can't be blank", "has already been taken"]
    }
  }
}
```

##### Get an Authentication

```
GET /api/provider_authentications/:id.json
```

##### Update an authentication

```
PUT|PATCH /api/provider_authentications/:id.json
```

This endpoint is meant to be used to update the provider access token or secret, no other data on the provider authentication can be updated.


##### Delete an Authentication (Unlink from a social network)

```
DELETE /api/provider_authentications/:id.json
```

This endpoint is meant to delete a provider authentication, therefore unlinking the given social network account.

##### Initiate a password reset

```
POST /api/passwords/forgot.json
```

This endpoint is meant to be used for associating new social networks to an existing account.

Request JSON:

```ruby
{
  "user": {
    "username": <string> # Required
  }
}
```

Successful Response (HTTP Status 200):

```ruby
{
  "meta": {
    message: "Please check your email for instructions to reset your password."
  }
}
```

Errors may only be generated if `Rockauth::Configuration.forgot_password_always_successful = false`

Example Error Response (HTTP Status 400):

```ruby
{
  "error": {
    "status_code": 400,
    "message": "We could not find your account with the information provided. Please try again or contact your administrator for support.",
    "validation_errors": {
      "username": ["is invalid"]
    }
  }
}
```

##### Complete a password reset

```
POST /api/passwords/reset.json
```

```ruby
{
  "user": {
    "password_reset_token": <string>, # Required
    "password":             <string>  # Required
  }
}
```

Successful Response (HTTP Status 200):

```ruby
{
  "meta": {
    message: "Your password has been changed. You may now log in."
  }
}
```

Example Error Response (HTTP Status 400):

```ruby
{
  "error": {
    "status_code": 400,
    "message": "We could not find your account with the information provided. Please try again or contact your administrator for support.",
    "validation_errors": {
      "password_reset_token": ["is invalid"],
      "password": ["is invalid"]
    }
  }
}
```

## Supported Versions

Rails >= 4.2.0

Ruby >= 2.1.0

## Contributing

## License

See MIT-LICENSE
