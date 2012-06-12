class UserActivationsController < ApplicationController
  skip_before_filter :signed_in_user
  
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
  
  def update
    @user = User.find_by_activation_token(params[:id])
    if @user
      @user.activate
      redirect_to signin_path, notice: "Account has been activated... please sign in to continue"
    else
      redirect_to account_activation_required_path, 
        alert: "Error occured when activating account, invalid account token"
    end
  end
end
