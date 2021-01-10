require "rails_helper"

RSpec.describe "Sessions", type: :request do
  before do
    @user = FactoryBot.create(:user)
  end

  describe "/login" do
    example "ログインできること" do
      params = {
        session: {
          email: @user.email,
          password: "password"
        }
      }
      post "/login", params: params
      expect(response).to have_http_status(:ok)
    end

    example "レスポンスボディに秘密情報が含まれていないこと" do
      params = {
        session: {
          email: @user.email,
          password: "password"
        }
      }
      post "/login", params: params
      response_user_keys = JSON.parse(response.body).keys
      expect(
        [
          response_user_keys.include?("password_digest"),
          response_user_keys.include?("reset_digest"),
          response_user_keys.include?("activation_digest"),
        ]
      ).to eq [false, false, false]
    end

    example "対象のユーザーがアクティブではない場合にアクセス禁止のステータスが返却されること" do
      new_user = FactoryBot.create(:user, email: "test@example.com", state: :inactive)
      params = {
        session: {
          email: new_user.email,
          password: "password"
        }
      }
      post "/login", params: params
      expect(response).to have_http_status(:forbidden)
    end

    example "対象のユーザーがアクティブではない場合にエラーメッセージが返却されること" do
      new_user = FactoryBot.create(:user, email: "test@example.com", state: :inactive)
      params = {
        session: {
          email: new_user.email,
          password: "password"
        }
      }
      post "/login", params: params
      error_message = "アカウントは有効になっていません。メールをご確認ください。"
      expect(JSON.parse(response.body)["error"]["message"]).to eq error_message
    end

    example "ログイン認証が失敗した場合に未認証のステータスが返却されること" do
      params = {
        session: {
          email: @user.email,
          password: "test"
        }
      }
      post "/login", params: params
      expect(response).to have_http_status(:unauthorized)
    end

    example "ログイン認証が失敗した場合ににエラーメッセージが返却されること" do
      params = {
        session: {
          email: @user.email,
          password: "test"
        }
      }
      post "/login", params: params
      error_message = "メールアドレスとパスワードの組み合わせが無効です。"
      expect(JSON.parse(response.body)["error"]["message"]).to eq error_message
    end
  end

  describe "/logout" do
    example "ログアウトできること" do
      params = {
        session: {
          email: @user.email,
          password: "password"
        }
      }
      post "/login", params: params
      delete "/logout"
      expect(response).to have_http_status(:ok)
    end
  end
end
