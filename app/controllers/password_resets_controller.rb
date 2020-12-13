class PasswordResetsController < ApplicationController
  before_action :set_user, only: [:edit, :update]
  before_action :valid_user?, only: [:edit, :update]
  before_action :expiration?, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      # flash.now[:info] = "パスワードリセット手順についての<br />メールを送信しました。"
    else
      # flash.now[:danger] = "ご入力したメールアドレスのアカウントは存在しません。"
    end
    # render "new"
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      # render "edit"
    elsif @user.update(user_params)
      # log_in @user
      # flash[:success] = "パスワードがリセットされました。"
      # redirect_to @user
    else
      # render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def set_user
    @user = User.find_by(email: params[:email])
  end

  # 有効なユーザーかどうか確認する
  def valid_user?
    return if (@user.present? && @user.activated? &&
               @user.authenticated?(:reset, params[:id]))

    # redirect_to "/422.html"
  end

  # トークンが期限切れかどうか確認する
  def expiration?
    return unless @user.password_reset_expired?

    # flash[:danger] = "パスワードのリセットが期限切れになりました。"
    # redirect_to new_password_reset_url
  end
end
