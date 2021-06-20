class UserMailer < ActionMailer::Base
  def welcome_email(user)
    @user = user
    @year = Year.where(year: user.year).first
    mail(
      :to => user.email,
      :reply_to => @year.reply_to_email,
      :subject => "Welcome to the #{user.year} U.S. Go Congress"
    )
  end
end
