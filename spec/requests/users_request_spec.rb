require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "/users" do
    describe "GET" do
      example "HTTPステータスが200 OKであること" do
        @admin_user = FactoryBot.create(:user, admin: true)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: @admin_user.id }
        )
        get "/users"
        expect(response).to have_http_status(:ok)
      end

      example "ユーザー 一覧が取得できること" do
        @admin_user = FactoryBot.create(:user, admin: true)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: @admin_user.id }
        )
        @user1 = FactoryBot.create(:user, name: "user1", email: "user1@example.com")
        @user2 = FactoryBot.create(:user, name: "user2", email: "user2@example.com")
        get "/users"
        users = JSON.parse(response.body, { symbolize_names: true })
        expect(users).to eq(
          [
            { id: @admin_user.id, name: @admin_user.name, email: @admin_user.email, displayState: @admin_user.display_state },
            { id: @user1.id, name: @user1.name, email: @user1.email, displayState: @user1.display_state },
            { id: @user2.id, name: @user2.name, email: @user2.email, displayState: @user2.display_state }
          ]
        )
      end

      example "ユーザーに権限がない場合にHTTPステータスが401 Unauthorizedであること" do
        user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: user.id }
        )
        get "/users"
        expect(response).to have_http_status(:unauthorized)
      end

      example "ログインしていない場合にHTTPステータスが401 Unauthorizedであること" do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: nil }
        )
        get "/users"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "POST" do
      example "ユーザーが作成できること" do
        params = {
          user: {
            name: "test",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
        post("/users", params:)
        expect(response).to have_http_status(:created)
      end

      example "ユーザー作成時にアカウント有効化用のメールを送信すること" do
        params = {
          user: {
            name: "test",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
        ActiveJob::Base.queue_adapter = :test
        expect do
          perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
            post("/users", params:)
          end
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      example "ユーザー作成後のユーザー情報が取得できること" do
        params = {
          user: {
            name: "test",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password"
          }
        }
        post("/users", params:)
        user = JSON.parse(response.body, { symbolize_names: true })
        create_user = User.find_by(email: "test@example.com")
        expect(user).to eq(
          {
            id: create_user.id, name: create_user.name, email: create_user.email, displayState: create_user.display_state,
            displayRole: create_user.display_role, displayCreatedAt: create_user.display_created_at,
            displayActivatedAt: create_user.display_activated_at, displayLockedAt: create_user.display_locked_at,
            admin: create_user.admin
          }
        )
      end

      example "バリデーションエラー時にHTTPステータスが422 Unprocessable Entityであること" do
        params = {
          user: {
            name: "test",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password1"
          }
        }
        post("/users", params:)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      example "バリデーションエラー時にエラーメッセージが返却されること" do
        params = {
          user: {
            name: "test",
            email: "test@example.com",
            password: "password",
            password_confirmation: "password1"
          }
        }
        post("/users", params:)
        result = JSON.parse(response.body, { symbolize_names: true })
        expect(result[:passwordConfirmation]).to include(I18n.t("errors.messages.confirmation"))
      end
    end
  end

  describe "/users/:id" do
    before do
      @user1 = FactoryBot.create(:user, name: "user1", email: "user1@example.com")
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
        { user_id: @user1.id }
      )
    end

    describe "GET" do
      example "HTTPステータスが200 OKであること" do
        get "/users/#{@user1.id}"
        expect(response).to have_http_status(:ok)
      end

      example "ユーザー情報が取得できること" do
        get "/users/#{@user1.id}"
        user = JSON.parse(response.body, { symbolize_names: true })
        expect(user).to eq(
          {
            id: @user1.id, name: @user1.name, email: @user1.email, displayState: @user1.display_state,
            displayRole: @user1.display_role, displayCreatedAt: @user1.display_created_at,
            displayActivatedAt: @user1.display_activated_at, displayLockedAt: @user1.display_locked_at,
            admin: @user1.admin
          }
        )
      end

      example "指定したユーザーの権限がない場合にHTTPステータスが401 Unauthorizedであること" do
        user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
        user2 = FactoryBot.create(:user, name: "user2", email: "user2@example.com", admin: false)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: user.id }
        )
        get "/users/#{user2.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "PUT" do
      example "HTTPステータスが200 OKであること" do
        put "/users/#{@user1.id}", params: { user: { name: "test" } }
        expect(response).to have_http_status(:ok)
      end

      example "ユーザー情報が更新できること" do
        put "/users/#{@user1.id}", params: { user: { name: "test" } }
        user = JSON.parse(response.body, { symbolize_names: true })
        expect(user[:name]).to eq "test"
      end

      example "更新後のユーザー情報が取得できること" do
        put "/users/#{@user1.id}", params: { user: { name: "test" } }
        user = JSON.parse(response.body, { symbolize_names: true })
        @user1.reload
        expect(user).to eq(
          {
            id: @user1.id, name: @user1.name, email: @user1.email, displayState: @user1.display_state,
            displayRole: @user1.display_role, displayCreatedAt: @user1.display_created_at,
            displayActivatedAt: @user1.display_activated_at, displayLockedAt: @user1.display_locked_at,
            admin: @user1.admin
          }
        )
      end

      example "バリデーションエラー時にHTTPステータスが422 Unprocessable Entityであること" do
        put "/users/#{@user1.id}", params: { user: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      example "バリデーションエラー時にエラーメッセージが返却されること" do
        put "/users/#{@user1.id}", params: { user: { name: "" } }
        result = JSON.parse(response.body, { symbolize_names: true })
        expect(result[:name]).to include(I18n.t("errors.messages.blank"))
      end

      example "指定したユーザーの権限がない場合にHTTPステータスが401 Unauthorizedであること" do
        user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
        user2 = FactoryBot.create(:user, name: "user2", email: "user2@example.com", admin: false)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: user.id }
        )
        put "/users/#{user2.id}", params: { user: { name: "test" } }
        expect(response).to have_http_status(:unauthorized)
      end

      describe "/users/:id/lock" do
        example "HTTPステータスが200 OKであること" do
          put "/users/#{@user1.id}/lock"
          expect(response).to have_http_status(:ok)
        end

        example "ユーザーがロックされること" do
          put "/users/#{@user1.id}/lock"
          @user1.reload
          expect(@user1.state_locked?).to eq true
        end

        example "ユーザーに権限がない場合にHTTPステータスが401 Unauthorizedであること" do
          user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
            { user_id: user.id }
          )
          put "/users/#{@user1.id}/lock"
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "/users/:id/unlock" do
        example "HTTPステータスが200 OKであること" do
          user = FactoryBot.create(:user, email: "test@example.com",
                                          state: :locked, locked_at: Time.zone.now)
          put "/users/#{user.id}/unlock"
          expect(response).to have_http_status(:ok)
        end

        example "ユーザーがアンロックされること" do
          user = FactoryBot.create(:user, email: "test@example.com",
                                          state: :locked, locked_at: Time.zone.now)
          put "/users/#{user.id}/unlock"
          user.reload
          expect(user.state_active?).to eq true
        end

        example "ユーザーに権限がない場合にHTTPステータスが401 Unauthorizedであること" do
          user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
            { user_id: user.id }
          )
          put "/users/#{@user1.id}/lock"
          expect(response).to have_http_status(:unauthorized)
        end
      end

      describe "/users/:id/update_password" do
        example "HTTPステータスが200 OKであること" do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
            { user_id: @user1.id }
          )
          params = { user: { password: "password", password_confirmation: "password" } }
          put("/users/#{@user1.id}/update_password", params:)
          expect(response).to have_http_status(:ok)
        end

        example "パスワードが更新できること" do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
            { user_id: @user1.id }
          )
          params = { user: { password: "password", password_confirmation: "password" } }
          put("/users/#{@user1.id}/update_password", params:)
          @user1.reload
          expect(@user1.authenticate("password").present?).to eq true
        end

        example "パスワード更新後にユーザー情報が取得できること" do
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
            { user_id: @user1.id }
          )
          params = { user: { password: "password", password_confirmation: "password" } }
          put("/users/#{@user1.id}/update_password", params:)
          user = JSON.parse(response.body, { symbolize_names: true })
          expect(user).to eq(
            {
              id: @user1.id, name: @user1.name, email: @user1.email, displayState: @user1.display_state,
              displayRole: @user1.display_role, displayCreatedAt: @user1.display_created_at,
              displayActivatedAt: @user1.display_activated_at, displayLockedAt: @user1.display_locked_at,
              admin: @user1.admin
            }
          )
        end

        example "バリデーションエラー時にHTTPステータスが422 Unprocessable Entityであること" do
          params = { user: { password: "a", password_confirmation: "b" } }
          put("/users/#{@user1.id}/update_password", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "バリデーションエラー時にエラーメッセージが返却されること" do
          params = { user: { password: "a", password_confirmation: "b" } }
          put("/users/#{@user1.id}/update_password", params:)
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:password]).to include(I18n.t("errors.messages.too_short", count: 6))
        end

        example "指定したユーザーの権限がない場合にHTTPステータスが401 Unauthorizedであること" do
          user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
          user2 = FactoryBot.create(:user, name: "user2", email: "user2@example.com", admin: false)
          allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
            { user_id: user.id }
          )
          params = { user: { password: "password", password_confirmation: "password" } }
          put("/users/#{user2.id}/update_password", params:)
          expect(response).to have_http_status(:unauthorized)
        end

        example "パスワードが空白の場合にエラーになること" do
          params = { user: { password: "", password_confirmation: "password" } }
          put("/users/#{@user1.id}/update_password", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "パスワードの確認が空白の場合にエラーになること" do
          params = { user: { password: "password", password_confirmation: "" } }
          put("/users/#{@user1.id}/update_password", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "パスワードが空白の場合にエラーメッセージを取得できること" do
          params = { user: { password: "", password_confirmation: "password" } }
          put("/users/#{@user1.id}/update_password", params:)
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:error][:message]).to eq I18n.t("errors.display_message.password_reset.blank")
        end
      end
    end

    describe "DELETE" do
      example "HTTPステータスが204 No Contentであること" do
        delete "/users/#{@user1.id}"
        expect(response).to have_http_status(:no_content)
      end

      example "ユーザーに権限がない場合にHTTPステータスが401 Unauthorizedであること" do
        user = FactoryBot.create(:user, name: "user", email: "user@example.com", admin: false)
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
          { user_id: user.id }
        )
        delete "/users/#{@user1.id}"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
