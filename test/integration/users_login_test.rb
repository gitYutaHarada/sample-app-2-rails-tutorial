require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  test "メールアドレスは正しいが、パスワードが誤っている状態でのログイン.セッションに何も入っていないことを確認" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: { session: { email: @user.email, password: "inavlid" } }
    assert_not !session[:user_id].nil?
    assert_response :unprocessable_entity
    assert_template "sessions/new"
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "正しい情報でログインしその後正常にログアウト可能かテスト" do
    post login_path, params: { session: { email:    @user.email,
                                          password: "password" } }
    assert !session[:user_id].nil?
    # リダイレクト先が正しいかチェック
    assert_redirected_to @user
    # 実際にそのページに移動
    follow_redirect!
    assert_template "users/show"
    # ログインされていればログイン用リンクは無いはず
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user) # user_path(@user) == /users/1

    delete logout_path
    assert_not !session[:user_id].nil?
    assert_response :see_other
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
