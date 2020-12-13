class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "アカウント登録のお知らせ"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "パスワードリセットのお知らせ"
  end
end
