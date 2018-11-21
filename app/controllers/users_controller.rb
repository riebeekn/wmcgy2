class UsersController < ApplicationController
  skip_before_filter :signed_in_user, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if user_exists_and_is_not_activated(@user.email)
      redirect_to account_activation_required_path,
                  notice: "Email already exists #{t(:activate_account, scope: 'flash_messages').downcase}"

    elsif(ENV['registration_locked'] == "true")
      redirect_to signin_path, alert: t(:registration_locked, scope: 'flash_messages')
    else
      if @user.save
        @user.send_activation_email
        redirect_to signin_path, notice: "Sign up complete, check your email for activation instructions"
      else
        render 'new'
      end
    end
  end

  def edit
    @user = current_user
  end

  def change_password
    @user = current_user
    @user.should_validate_password = true

    if @user.authenticate(params[:old_password]) == false
      @old_pswd_class = "error"
      @old_pswd_span = "<span class='help-inline'>incorrect old password</span>"
      render 'edit'
      return
    end

    if @user.update_attributes(params[:user]) == true
      redirect_to account_path, notice: "Password updated"
    else
      render 'edit'
    end
  end

  def update_email
    @user = User.find(current_user)

    if @user.update_attributes(params[:user])
      redirect_to account_path, notice: "Email updated"
    else
      render 'edit'
    end
  end

  def destroy
    current_user.destroy
    redirect_to signin_path, notice: "Account closed!"
  end

  private

    def user_exists_and_is_not_activated(email)
      existing_user = User.find_by_email(email)
      existing_user && !existing_user.active?
    end
end
