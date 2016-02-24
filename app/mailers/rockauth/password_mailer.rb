class Rockauth::PasswordMailer < ActionMailer::Base
  def reset email, token, resource_owner=nil
    @token = token
    @resource_owner = resource_owner
    mail to: email, from: Rockauth::Configuration.email_from
  end
end
