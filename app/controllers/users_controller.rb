class UsersController < ApplicationController
  skip_before_filter :signed_in_user
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    if user_exists_and_is_not_activated(@user.email)
      redirect_to account_activation_required_path, 
                  notice: "Email already exists #{t(:activate_account, scope: 'flash_messages').downcase}" 
    elsif @user.save
      @user.send_activation_email
      redirect_to signin_path, notice: "Sign up complete, check your email for activation instructions"
    else
      render 'new'
    end
  end
  
  private
  
    def user_exists_and_is_not_activated(email)
      existing_user = User.find_by_email(email)
      existing_user && !existing_user.active?
    end
end
