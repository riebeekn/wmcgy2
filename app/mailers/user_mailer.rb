class UserMailer < ActionMailer::Base
  default from: "from@example.com"

  def activation(user)
    @user = user
    mail to: user.email, subject: "Activate your website_name account"
  end
  
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end