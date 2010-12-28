class UserMailer < ActionMailer::Base
  default :from => "usgcwebsite@gmail.com"
  
  def welcome_email(user)
	  @user = user
    mail(:to => user.email,
         :subject => "Welcome to USGC")
  end
  
end
