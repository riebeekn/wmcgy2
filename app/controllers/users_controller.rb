class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @existing_user = User.find_by_email(@user.email)
    if @existing_user && !@existing_user.active?
      redirect_to account_activation_required_path, 
                  notice: "Email already exists #{t(:activate_account, scope: 'flash_messages').downcase}" 
    elsif @user.save
      @user.send_activation_email
      redirect_to signin_path, notice: "Sign up complete, check your email for activation instructions"
    else
      render 'new'
    end
  end
end
