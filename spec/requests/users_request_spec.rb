require "rails_helper"
include ActiveJob::TestHelper

RSpec.describe "Users", type: :request do
  describe "/users" do
    describe "GET" do
      before do
        @user1 = FactoryBot.create(:user, name: "user1", email: "user1@example.com")
        @user2 = FactoryBot.create(:user, name: "user2", email: "user2@example.com")
      end

      example "HTTPステータスが200 OKであること" do
        get "/users"
        expect(response).to have_http_status(:ok)
      end

      example "ユーザー一覧が取得できること" do
        get "/users"
        users = JSON.parse(response.body, { symbolize_names: true })
        expect(users).to eq(
          [
            { id: @user1.id, name: @user1.name, email: @user1.email, admin: @user1.admin },
            { id: @user2.id, name: @user2.name, email: @user2.email, admin: @user2.admin }
          ]
        )
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
        post "/users", params: params
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
            post "/users", params: params
          end
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
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
        post "/users", params: params
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
        post "/users", params: params
        expect(JSON.parse(response.body)["passwordConfirmation"]).to eq(I18n.t("errors.messages.confirmation"))
      end
    end
  end

  describe "/users/:id" do
    before do
      @user1 = FactoryBot.create(:user, name: "user1", email: "user1@example.com")
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
          { id: @user1.id, name: @user1.name, email: @user1.email, admin: @user1.admin },
        )
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

      example "バリデーションエラー時にHTTPステータスが422 Unprocessable Entityであること" do
        put "/users/#{@user1.id}", params: { user: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      example "バリデーションエラー時にエラーメッセージが返却されること" do
        put "/users/#{@user1.id}", params: { user: { name: "" } }
        expect(JSON.parse(response.body)["name"]).to eq(I18n.t("errors.messages.blank"))
      end
    end

    describe "DELETE" do
      example "HTTPステータスが204 No Contentであること" do
        delete "/users/#{@user1.id}"
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
