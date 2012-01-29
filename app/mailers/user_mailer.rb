class UserMailer < ActionMailer::Base
  default :from => "usgcwebsite@gmail.com"
  
  def welcome_email(user)
    @user = user
    mail(:to => user.email,
      :reply_to => 'registrar@gocongress.org',
      :subject => "Welcome to the " + CONGRESS_YEAR.to_s + " US Go Congress")
  end
  
end
