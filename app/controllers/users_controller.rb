class UsersController < ApplicationController
  before_action -> {
    if (user_id = session[:user_id])
      if @current_user.nil?
        @current_user = User.find_by(id: user_id)
      elsif (user_id = cookies.encrypted[:user_id])
        user = User.find_by(id: user_id)
        if user && BCrypt::Password.new(user.remember_digest).is_password?(cookies[:remember_token])
          sessions[:user_id] = user.id
          @current_user = user
        end
      end
    end
    unless !@current_user.nil?
      flash[:danger] = "Please log in"
      redirect_to login_url, status: :see_other
    end
  }, only: [ :edit, :update ]
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :email, :password, :password_confirmation))
    if @user.save
      reset_session
      session[:user_id] = @user.id
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find_by(id: params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(params.require(:user).permit(:name, :email, :password, :password_confirmation))
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render "edit", status: :unprocessable_entity
    end
  end
end
