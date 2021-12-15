class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user
    @url = generate_edit_account_activation_url(@user)
    mail to: user.email, subject: "アカウント登録のお知らせ"
  end

  def password_reset(user)
    @user = user
    @url = generate_edit_password_reset_url(@user)
    mail to: user.email, subject: "パスワードリセットのお知らせ"
  end

  private

  def generate_edit_account_activation_url(user)
    query = { token: user.activation_token, email: user.email }.to_query
    "localhost/accountactivations?#{query}"
  end

  def generate_edit_password_reset_url(user)
    query = { token: user.reset_token, email: user.email }.to_query
    "localhost/passwordresets?#{query}"
  end
end
