class SessionsController < ApplicationController
  skip_before_filter :signed_in_user
  
  def new
    @session = Session.new
    @user = User.new
  end
  
  def create
    @user = User.new
    @session = Session.new(params[:session])
    
    if env['omniauth.auth'].nil? 
      # custom login
      user = User.find_by_email(@session.email.downcase)
      if user && user.authenticate(@session.password)
        if user.active?
          set_auth_cookie user, @session
          redirect_to root_path
        else
          redirect_to account_activation_required_path, 
                      notice: t(:activate_account, scope: 'flash_messages')
        end
      else
        flash.now.alert = "Invalid email/password combination"
        render "new"
      end
    else
      # omniauth login
      user = User.from_omniauth(env["omniauth.auth"])
      set_auth_cookie user, @session
      redirect_to root_path
    end
  end

  def destroy
    cookies.delete(:auth_token)
    redirect_to signin_path, notice: "Signed out!"
  end
  
  def failure
    redirect_to signin_path, alert: "Authentication failed, please try again."
  end
  
  private
    def set_auth_cookie(user, session)
      if session.remember_me?
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
    end 
end
