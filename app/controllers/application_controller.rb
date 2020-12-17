class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user.present? && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    user.present? && user == current_user
  end

  # 管理者確認
  def admin?
    current_user.admin?
  end

  def current_user_name
    current_user.name
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    current_user.present?
  end

  # ユーザーのログインを確認する
  def logged_in_user?
    return if logged_in?

    render status: :unauthorized
  end

  def response_error(message)
    {
      error: { message: message }
    }.to_json
  end
end
