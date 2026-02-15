class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      reset_session
      user.remember_token = SecureRandom.urlsafe_base64
      if ActiveModel::SecurePassword.min_cost
        cost = BCrypt::Engine::MIN_COST
      else
        cost = BCrypt::Engine.cost
      end
      digest_string = BCrypt::Password.create(user.remember_token, cost: cost)
      user.update_attribute(:remember_digest, digest_string)
      cookies.permanent.encrypted[:user_id] = user.id
      cookies.permanent[:remember_token] = user.remember_token
      session[:user_id] = user.id
      redirect_to user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new", status: :unprocessable_entity
    end
  end

  def destroy
    @user = User.find_by(id: session[:user_id])
    if @user
      @user.update_attribute(:remember_digest, nil)
    end
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
    reset_session
    @current_user = nil
    redirect_to root_url, status: :see_other
  end
end
