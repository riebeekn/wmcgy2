class PasswordResetsController < ApplicationController
  skip_before_filter :signed_in_user
  
  def new
    @email = Email.new
  end
  
  def create
    @email = Email.new(params[:email])
    if @email.valid?
      user = User.find_by_email(@email.email)
      if user && user.active
        user.send_password_reset_email
        redirect_to signin_path, notice: t(:email_sent, scope: 'flash_messages.password_resets')
      elsif user && !user.active
        redirect_to account_activation_required_path, notice: 'Your account has not been activated'
      else
        redirect_to signin_path, notice:  t(:email_sent, scope: 'flash_messages.password_resets')
      end
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find_by_password_reset_token(params[:id])
    if @user.nil?
      redirect_to forgot_password_path, notice: t(:invalid_token, scope: 'flash_messages.password_resets')
    elsif !@user.active
      redirect_to account_activation_required_path
    end
  end
  
  def update
    @user = User.find_by_password_reset_token(params[:id])
    @user.should_validate_password = true if @user
    
    if @user.nil?
      redirect_to forgot_password_path, alert: t(:invalid_token, scope: 'flash_messages.password_resets')
    elsif !@user.active?
      redirect_to account_activation_required_path
    elsif @user.password_reset_sent_at < 2.hours.ago
      redirect_to forgot_password_path, alert: "Password reset has expired."
    elsif @user.update_attributes(params[:user])
      redirect_to signin_path, notice: "Password has been reset... please sign in to continue"
    else
      render :edit
    end
  end
end
