class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    except = [:password_digest, :remember_digest, :reset_digest, :activation_digest]
    if user.present? && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == "1" ? remember(user) : forget(user)
        render json: user.as_json(except: except), status: :ok
      else
        render json: user.as_json(except: except), status: :locked
      end
    else
      render json: {}, status: :unauthorized
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
  end

  # ユーザー情報を永続的にcookieに格納する
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 永続的cookieを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
