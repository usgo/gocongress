class UserMailer < ActionMailer::Base
  default :from => "usgcwebsite@gmail.com"
  
  def welcome_email(user)
    @host = default_url_options[:host]
    @port = default_url_options[:port]
    @lrFormUrl = "http://" + @host + ":" + @port.to_s + "/docs/USGC2011-Liability-Release-Form.doc"
    mail(:to => user.email,
      :reply_to => 'registrar@gocongress.org',
      :subject => "Welcome to the " + CONGRESS_YEAR.to_s + " US Go Congress")
  end
  
end
