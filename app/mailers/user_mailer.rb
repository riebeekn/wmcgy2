class UserMailer < ActionMailer::Base
  default from: "noReply@wheredidmycashgoyo.com"

  def activation(user)
    @user = user
    mail to: user.email, subject: "Welcome to where did my cash go yo!"
  end
  
  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset for where did my cash go yo"
  end
end