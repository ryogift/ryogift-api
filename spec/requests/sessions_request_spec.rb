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
          password: "password",
          remember_me: "1"
        }
      }
      post "/login", params: params
      expect(response).to have_http_status(:ok)
    end

    example "レスポンスボディに秘密情報が含まれていないこと" do
      params = {
        session: {
          email: @user.email,
          password: "password",
          remember_me: "1"
        }
      }
      post "/login", params: params
      response_user_keys = JSON.parse(response.body).keys
      expect(
        [
          response_user_keys.include?("password_digest"),
          response_user_keys.include?("remember_digest"),
          response_user_keys.include?("reset_digest"),
          response_user_keys.include?("activation_digest"),
        ]
      ).to eq [false, false, false, false]
    end

    example "対象のユーザーがアクティブではない場合にロック中のステータスが返却されること" do
      new_user = FactoryBot.create(:user, email: "test@example.com", activated: false)
      params = {
        session: {
          email: new_user.email,
          password: "password",
          remember_me: "1"
        }
      }
      post "/login", params: params
      expect(response).to have_http_status(:locked)
    end

    example "対象のユーザーがアクティブではない場合にレスポンスボディに秘密情報が含まれていないこと" do
      new_user = FactoryBot.create(:user, email: "test@example.com", activated: false)
      params = {
        session: {
          email: new_user.email,
          password: "password",
          remember_me: "1"
        }
      }
      post "/login", params: params
      response_user_keys = JSON.parse(response.body).keys
      expect(
        [
          response_user_keys.include?("password_digest"),
          response_user_keys.include?("remember_digest"),
          response_user_keys.include?("reset_digest"),
          response_user_keys.include?("activation_digest"),
        ]
      ).to eq [false, false, false, false]
    end

    example "ログイン認証が失敗した場合に未認証のステータスが返却されること" do
      params = {
        session: {
          email: @user.email,
          password: "test",
          remember_me: "1"
        }
      }
      post "/login", params: params
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "/logout" do
    example "ログアウトできること" do
      params = {
        session: {
          email: @user.email,
          password: "password",
          remember_me: "1"
        }
      }
      post "/login", params: params
      delete "/logout"
      expect(response).to have_http_status(:ok)
    end
  end
end
