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
      post("/login", params:)
      expect(response).to have_http_status(:ok)
    end

    example "ユーザー情報が取得できること" do
      params = {
        session: {
          email: @user.email,
          password: "password"
        }
      }
      post("/login", params:)
      user = JSON.parse(response.body, { symbolize_names: true })
      expect(user).to eq(
        {
          id: @user.id, name: @user.name, email: @user.email, displayState: @user.display_state,
          displayRole: @user.display_role, displayCreatedAt: @user.display_created_at,
          displayActivatedAt: @user.display_activated_at, displayLockedAt: @user.display_locked_at,
          admin: @user.admin
        }
      )
    end

    example "対象のユーザーがアクティブではない場合にアクセス禁止のステータスが返却されること" do
      new_user = FactoryBot.create(:user, email: "test@example.com", state: :inactive)
      params = {
        session: {
          email: new_user.email,
          password: "password"
        }
      }
      post("/login", params:)
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
      post("/login", params:)
      error_message = I18n.t("errors.display_message.auth.forbidden")
      result = JSON.parse(response.body, { symbolize_names: true })
      expect(result[:error][:message]).to eq error_message
    end

    example "ログイン認証が失敗した場合に未認証のステータスが返却されること" do
      params = {
        session: {
          email: @user.email,
          password: "test"
        }
      }
      post("/login", params:)
      expect(response).to have_http_status(:unauthorized)
    end

    example "ログイン認証が失敗した場合にエラーメッセージが返却されること" do
      params = {
        session: {
          email: @user.email,
          password: "test"
        }
      }
      post("/login", params:)
      error_message = I18n.t("errors.display_message.auth.unauthorized")
      result = JSON.parse(response.body, { symbolize_names: true })
      expect(result[:error][:message]).to eq error_message
    end

    example "アカウントがロックされている場合にロックのステータスが返却されること" do
      user = FactoryBot.create(:user, email: "test@example.com", password_digest: User.digest("password"),
                                      state: :locked, locked_at: Time.zone.now)
      params = {
        session: {
          email: user.email,
          password: "password"
        }
      }
      post("/login", params:)
      expect(response).to have_http_status(:locked)
    end

    example "アカウントがロックされている場合にエラーメッセージが返却されること" do
      user = FactoryBot.create(:user, email: "test@example.com", password_digest: User.digest("password"),
                                      state: :locked, locked_at: Time.zone.now)
      params = {
        session: {
          email: user.email,
          password: "password"
        }
      }
      post("/login", params:)
      error_message = I18n.t("errors.display_message.auth.locked")
      result = JSON.parse(response.body, { symbolize_names: true })
      expect(result[:error][:message]).to eq error_message
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
      post("/login", params:)
      delete "/logout"
      expect(response).to have_http_status(:ok)
    end
  end

  describe "/client_user" do
    before do
      params = {
        session: {
          email: @user.email,
          password: "password"
        }
      }
      post("/login", params:)
    end

    example "HTTPステータスが200 OKであること" do
      get "/client_user"
      expect(response).to have_http_status(:ok)
    end

    example "ログイン済みのユーザー情報が取得できること" do
      get "/client_user"
      user = JSON.parse(response.body, { symbolize_names: true })
      expect(user).to eq(
        {
          id: @user.id, name: @user.name, email: @user.email, displayState: @user.display_state,
          displayRole: @user.display_role, displayCreatedAt: @user.display_created_at,
          displayActivatedAt: @user.display_activated_at, displayLockedAt: @user.display_locked_at,
          admin: @user.admin
        }
      )
    end
  end
end
