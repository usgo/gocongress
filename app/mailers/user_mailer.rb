class UserMailer < ActionMailer::Base
  default :from => "usgcwebsite@gmail.com"

  def welcome_email(user)
    @user = user
    @year = Year.find_by_year(user.year)
    mail(:to => user.email,
      :reply_to => @year.reply_to_email,
      :subject => "Welcome to the #{user.year} US Go Congress")
  end

end
