class UserMailer < ActionMailer::Base
  default :from => "usgcwebsite@gmail.com"

  def welcome_email(user)
    @user = user
    mail(:to => user.email,
      :reply_to => reply_to(user.year),
      :subject => "Welcome to the #{user.year} US Go Congress")
  end

private

  def reply_to(year)
    raise "reply-to undefined" if MAILER_REPLY_TO[year].blank?
    return MAILER_REPLY_TO[year]
  end

end
