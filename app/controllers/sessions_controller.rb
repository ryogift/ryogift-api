class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    except = [:password_digest, :reset_digest, :activation_digest]
    if user.present? && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        cookies.signed[:user_id] = user.id
        render json: user.as_json(except: except), status: :ok
      else
        error_message = "アカウントが有効になっていません。メールを確認してください。"
        render json: response_error(error_message), status: :locked
      end
    else
      error_message = "メールアドレスとパスワードの組み合わせが無効です。"
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
  end

  # 現在のユーザーをログアウトする
  def log_out
    cookies.delete(:user_id)
    session.delete(:user_id)
    @current_user = nil
  end
end
