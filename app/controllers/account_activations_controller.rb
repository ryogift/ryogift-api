class AccountActivationsController < ApplicationController
  # PUT /account_activations/:id
  def update
    user = User.find_by(email: user_params[:email])
    if user.present? && user.state_inactive? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in(user)
      user_json = user.to_display_json
      render json: lower_camelize_keys(user_json)
    else
      error_message = I18n.t("errors.display_message.account_activations.unauthorized")
      render json: response_error(error_message), status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

  def log_in(user)
    session[:user_id] = user.id
    cookies.signed[:user_id] = user.id
  end
end
