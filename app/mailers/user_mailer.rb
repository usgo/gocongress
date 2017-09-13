class UserMailer < ActionMailer::Base
  default :from => "usgcwebsite@gmail.com"

  def welcome_email(user)
    @user = user
    @year = Year.where(year: user.year).first
    mail(:to => user.email,
      :reply_to => @year.reply_to_email,
      :subject => "Welcome to the #{user.year} U.S. Go Congress")
  end

end
