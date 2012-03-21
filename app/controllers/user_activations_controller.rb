class UserActivationsController < ApplicationController
  
  def update
    @user = User.find_by_activation_token(params[:id])
    if @user
      @user.activate
      redirect_to signin_path, notice: "Account has been activated"
    else
      redirect_to account_activation_required_path, 
        alert: "Error occured when activating account, invalid account token"
    end
  end
  
  def new
    @email = Email.new
  end
  
  def create
    @email = Email.new(params[:email])
    if @email.valid?
      user = User.find_by_email(@email.email)
      user.send_activation_email if user
      redirect_to signin_path, notice: "Email sent"
    else
      render :new
    end
  end
end
