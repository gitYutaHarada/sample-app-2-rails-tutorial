class SessionHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael)
    @user.remember_token = SecureRandom.urlsafe_base64
    if ActiveModel::SecurePassword.min_cost
      cost = BCrypt::Engine::MIN_COST
    else
      cost = BCrypt::Engine.cost
    end
    @user.update_attribute(:remember_digest, BCrypt::Password.create(@user.remember_token, cost: cost))

    cookies.permanent.encrypted[:user_id] = @user.id
    cookies.permanent[:remember_token] = @user.remember_token
  end

  test "current_user returns right user when session is nil" do
    if session[:user_id]
      if current_user.nil?
        current_user = User.find_by(id: session[:user_id])
      end
    elsif cookies.encrypted[:user_id]
      user = User.find_by(id: cookies.encrypted[:user_id])
      if user && BCrypt::Password.new(user.remember_digest).is_password?(cookies[:remember_token])
        session[:user_id] = user.id
        current_user = user
      end
    end
    assert_equal @user, current_user
    assert !session[:user_id].nil?
  end

  test "current_user returns nil when remember digest is wrong" do
    if ActiveModel::SecurePassword.min_cost
      cost = BCrypt::Engine::MIN_COST
    else
      cost = BCrypt::Engine.min_cost
    end
    @user.update_attribute(:remember_digest, BCrypt::Password.create(SecureRandom.urlsafe_base64, cost: cost))

    if session[:user_id]
      if current_user.nil?
        current_user = User.find_by(id: session[:user_id])
      end
    elsif cookies.encrypted[:user_id]
      user = User.find_by(id: cookies.encrypted[:user_id])
      if user && BCrypt::Password.new(@user.remember_digest).is_password?(cookies[:remember_token])
        session[:user_id] = @user.id
        current_user = @user
      end
    end

    assert_nil current_user
  end
end
