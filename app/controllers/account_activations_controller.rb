class AccountActivationsController < ApplicationController
  # PUT /account_activations/:id
  def update
    user = User.find_by(email: user_params[:email])
    if user.present? && user.state_inactive? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in(user)
      except = [:password_digest, :reset_digest, :activation_digest]
      render json: lower_camelize_keys(user.as_json(except: except))
    else
      error_message = "アカウントが有効になりませんでした。"
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
