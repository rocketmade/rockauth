class Rockauth::PasswordMailer < ActionMailer::Base

  def reset email, token
    @token = token
    mail to: email, from: Rockauth::Configuration.email_from
  end
end
