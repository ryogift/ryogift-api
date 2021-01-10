class SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    except = [:password_digest, :reset_digest, :activation_digest]
    if user.present? && user.authenticate(params[:session][:password])
      if user.state_locked?
        error_message = "アカウントは凍結されています。管理者にご連絡ください。"
        render json: response_error(error_message), status: :locked
      elsif user.state_active?
        log_in user
        render json: user.as_json(except: except), status: :ok
      else
        error_message = "アカウントは有効になっていません。メールをご確認ください。"
        render json: response_error(error_message), status: :forbidden
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
    cookies.signed[:user_id] = user.id
  end

  # 現在のユーザーをログアウトする
  def log_out
    cookies.delete(:user_id)
    session.delete(:user_id)
    @current_user = nil
  end
end
