class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.update_attribute(:activated, true)
      user.update_attribute(:activated_at, Time.zone.now)
      user.activate
      # login
      session[:user_id] = user.id
      except = [:password_digest, :reset_digest, :activation_digest]
      render json: lower_camelize_keys(user.as_json(except: except))
    else
      error_message = "アカウントが有効になりませんでした。"
      render json: response_error(error_message), status: :unauthorized
    end
  end
end
