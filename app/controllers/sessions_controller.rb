class SessionsController < ApplicationController
  skip_before_filter :signed_in_user
  
  def new
    @session = Session.new
    @user = User.new
  end
  
  def create
    @user = User.new
    @session = Session.new(params[:session])
    user = User.find_by_email(@session.email)
    if user && user.authenticate(@session.password)
      sign_in_if_active user, @session
    else
      flash.now.alert = "Invalid email/password combination"
      render "new"
    end
  end
  
  def destroy
    cookies.delete(:auth_token)
    redirect_to signin_path, notice: "Signed out!"
  end
  
  private
    def sign_in_if_active(user, session)
      if user.active?
        set_auth_cookie user, session
        redirect_to root_path
      else
        redirect_to account_activation_required_path, 
                    notice: t(:activate_account, scope: 'flash_messages')
      end
    end
    
    def set_auth_cookie(user, session)
      if session.remember_me?
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
    end 
  #end private
end
