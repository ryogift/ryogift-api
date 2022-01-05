class ApplicationController < ActionController::API
  include ActionController::Cookies

  private

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      user = User.find_by(id: cookies.signed[:user_id])
      if user.present?
        session[:user_id] = user.id
        cookies.signed[:user_id] = user.id
        @current_user = user
      end
    end
  end

  # 渡されたユーザーがカレントユーザーであればtrueを返す
  def current_user?(user)
    (user.present? && user == current_user) || current_user.admin?
  end

  # 管理者確認
  def admin?
    return if current_user.admin?

    render json: {}, status: :unauthorized
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    current_user.present?
  end

  # ユーザーのログインを確認する
  def logged_in_user?
    return if logged_in?

    render json: {}, status: :unauthorized
  end

  def response_error(message)
    {
      error: { message: }
    }.to_json
  end

  def lower_camelize_keys(object)
    if object.is_a?(Array)
      object.map { |item| item.transform_keys { |k| k.to_s.camelize(:lower).to_sym } }
    else
      object.transform_keys { |k| k.to_s.camelize(:lower).to_sym }
    end
  end
end
