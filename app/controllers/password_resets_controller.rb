class PasswordResetsController < ApplicationController
  # POST /password_resets
  def create
    user = User.find_by(email: params[:email].downcase)
    if user
      user.create_reset_digest
      user.send_password_reset_email
      render json: {}
    else
      error_message = I18n.t("errors.display_message.password_reset.not_found")
      render json: response_error(error_message), status: :not_found
    end
  end

  # PUT /password_resets/:id
  def update
    user = User.find_by(email: user_params[:email])

    # 有効なユーザーかどうか確認する
    unless user.present? && user.state_active? && user.authenticated?(:reset, params[:id])
      error_message = I18n.t("errors.display_message.password_reset.invalid")
      return render json: response_error(error_message), status: :unprocessable_entity
    end

    # トークンが期限切れかどうか確認する
    if user.password_reset_expired?
      error_message = I18n.t("errors.display_message.password_reset.expired")
      return render json: response_error(error_message), status: :unprocessable_entity
    end

    if user_params[:password].blank? || user_params[:password_confirmation].blank?
      error_message = I18n.t("errors.display_message.password_reset.blank")
      render json: response_error(error_message), status: :unprocessable_entity
    elsif user.update(password: user_params[:password], password_confirmation: user_params[:password_confirmation])
      render json: {}
    else
      render json: lower_camelize_keys(user.errors.as_json), status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
