require "rails_helper"

RSpec.describe "AccountActivations", type: :request do
  before do
    @user = FactoryBot.create(:user, state: :inactive, activated_at: nil, admin: nil)
  end

  describe "PUT" do
    describe "/account_activations/:id" do
      example "HTTPステータスが200 OKであること" do
        params = {
          user: {
            email: @user.email
          }
        }
        put("/account_activations/#{@user.activation_token}", params:)
        expect(response).to have_http_status(:ok)
      end

      example "アカウントをアクティブに変更できること" do
        params = {
          user: {
            email: @user.email
          }
        }
        put("/account_activations/#{@user.activation_token}", params:)
        @user.reload
        expect(@user.state_active?).to eq true
      end

      example "ログインしていること" do
        params = {
          user: {
            email: @user.email
          }
        }
        put("/account_activations/#{@user.activation_token}", params:)
        expect(session[:user_id]).to eq @user.id
      end

      example "ユーザー情報が取得できること" do
        params = {
          user: {
            email: @user.email
          }
        }
        put("/account_activations/#{@user.activation_token}", params:)
        user = JSON.parse(response.body, { symbolize_names: true })
        @user.reload
        expect(user).to eq(
          {
            id: @user.id, name: @user.name, email: @user.email, displayState: @user.display_state,
            displayRole: @user.display_role, displayCreatedAt: @user.display_created_at,
            displayActivatedAt: @user.display_activated_at, displayLockedAt: @user.display_locked_at,
            admin: @user.admin
          }
        )
      end

      describe "アクティブトークンが誤っている場合" do
        example "HTTPステータスが401 Unauthorizedであること" do
          params = {
            user: {
              email: @user.email
            }
          }
          put("/account_activations/test", params:)
          expect(response).to have_http_status(:unauthorized)
        end

        example "アカウントがアクティブにならないこと" do
          params = {
            user: {
              email: @user.email
            }
          }
          put("/account_activations/test", params:)
          @user.reload
          expect(@user.state_active?).to eq false
        end

        example "エラーメッセージが返却されること" do
          params = {
            user: {
              email: @user.email
            }
          }
          put("/account_activations/test", params:)
          error_message = I18n.t("errors.display_message.account_activations.unauthorized")
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:error][:message]).to eq error_message
        end
      end
    end
  end
end
