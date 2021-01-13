class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user.present? && user.authenticate(params[:session][:password])
      if user.state_locked?
        error_message = I18n.t("errors.display_message.auth.locked")
        render json: response_error(error_message), status: :locked
      elsif user.state_active?
        log_in user
        user_json = user.to_display_json
        render json: lower_camelize_keys(user_json), status: :ok
      else
        error_message = I18n.t("errors.display_message.auth.forbidden")
        render json: response_error(error_message), status: :forbidden
      end
    else
      error_message = I18n.t("errors.display_message.auth.unauthorized")
      render json: response_error(error_message), status: :unauthorized
    end
  end

  def destroy
    log_out if logged_in?
    render json: {}, status: :ok
  end

  private

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
    cookies.signed[:user_id] = user.id
  end

  # 現在のユーザーをログアウトする
  def log_out
    cookies.delete(:user_id)
    session.delete(:user_id)
    @current_user = nil
  end
end
