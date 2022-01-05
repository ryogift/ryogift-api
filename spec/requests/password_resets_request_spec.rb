require "rails_helper"

RSpec.describe "PasswordResets", type: :request do
  before do
    @user = FactoryBot.create(:user, state: :active, admin: nil)
  end

  describe "POST" do
    describe "/password_resets" do
      example "HTTPステータスが200 OKであること" do
        params = {
          user: {
            email: @user.email
          }
        }
        post("/password_resets", params:)
        expect(response).to have_http_status(:ok)
      end

      example "パスワード再設定のメールが送信されること" do
        params = {
          user: {
            email: @user.email
          }
        }
        ActiveJob::Base.queue_adapter = :test
        expect do
          perform_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
            post("/password_resets", params:)
          end
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      describe "パラメータに指定したメールアドレスが存在しない場合" do
        example "HTTPステータスが404 Not Foundであること" do
          params = {
            user: {
              email: "test@example.com"
            }
          }
          post("/password_resets", params:)
          expect(response).to have_http_status(:not_found)
        end

        example "HTTPステータスが404 Not Foundであること" do
          params = {
            user: {
              email: "test@example.com"
            }
          }
          post("/password_resets", params:)
          expect(response).to have_http_status(:not_found)
        end

        example "エラーメッセージが返却されること" do
          params = {
            user: {
              email: "test@example.com"
            }
          }
          post("/password_resets", params:)
          error_message = I18n.t("errors.display_message.password_reset.not_found")
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:error][:message]).to eq error_message
        end
      end
    end
  end

  describe "PUT" do
    describe "/password_resets/:id" do
      example "HTTPステータスが200 OKであること" do
        @user.create_reset_digest
        params = {
          user: {
            email: @user.email,
            password: "password",
            password_confirmation: "password"
          }
        }
        put("/password_resets/#{@user.reset_token}", params:)
        expect(response).to have_http_status(:ok)
      end

      example "パスワードが変更できること" do
        @user.create_reset_digest
        params = {
          user: {
            email: @user.email,
            password: "test1234",
            password_confirmation: "test1234"
          }
        }
        put("/password_resets/#{@user.reset_token}", params:)
        @user.reload
        expect(@user.authenticate("test1234").present?).to eq true
      end

      describe "パスワードまたはパスワードの確認が空白の場合" do
        example "HTTPステータスが422 Unprocessable Entityであること" do
          @user.create_reset_digest
          params = {
            user: {
              email: @user.email,
              password: "password",
              password_confirmation: ""
            }
          }
          put("/password_resets/#{@user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "エラーメッセージが返却されること" do
          @user.create_reset_digest
          params = {
            user: {
              email: @user.email,
              password: "password",
              password_confirmation: ""
            }
          }
          put("/password_resets/#{@user.reset_token}", params:)
          error_message = I18n.t("errors.display_message.password_reset.blank")
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:error][:message]).to eq error_message
        end

        example "パスワードが空白の場合にエラーになること" do
          @user.create_reset_digest
          params = {
            user: {
              email: @user.email,
              password: "",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{@user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "パスワードの確認が空白の場合にエラーになること" do
          @user.create_reset_digest
          params = {
            user: {
              email: @user.email,
              password: "password",
              password_confirmation: ""
            }
          }
          put("/password_resets/#{@user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      describe "バリデーションエラーの場合" do
        example "HTTPステータスが422 Unprocessable Entityであること" do
          @user.create_reset_digest
          params = {
            user: {
              email: @user.email,
              password: "password",
              password_confirmation: "test1234"
            }
          }
          put("/password_resets/#{@user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "エラーメッセージが返却されること" do
          @user.create_reset_digest
          params = {
            user: {
              email: @user.email,
              password: "password",
              password_confirmation: "test1234"
            }
          }
          put("/password_resets/#{@user.reset_token}", params:)
          error_message = I18n.t("errors.messages.confirmation")
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:passwordConfirmation]).to include(error_message)
        end
      end

      describe "アクティブなユーザーではない場合" do
        example "HTTPステータスが422 Unprocessable Entityであること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :inactive, admin: nil)
          user.create_reset_digest
          params = {
            user: {
              email: user.email,
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "エラーメッセージが返却されること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :inactive, admin: nil)
          user.create_reset_digest
          params = {
            user: {
              email: user.email,
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{user.reset_token}", params:)
          error_message = I18n.t("errors.display_message.password_reset.invalid")
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:error][:message]).to eq error_message
        end

        example "パラメータに指定したメールアドレスが存在しない場合にエラーになること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :active, admin: nil)
          user.create_reset_digest
          params = {
            user: {
              email: "test1@example.com",
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "非アクティブの場合にエラーになること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :inactive, admin: nil)
          user.create_reset_digest
          params = {
            user: {
              email: user.email,
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "リセットトークンが異なる場合にエラーになること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :active, admin: nil)
          user.create_reset_digest
          params = {
            user: {
              email: user.email,
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/test", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      describe "パスワード再設定の期限が切れている場合" do
        example "HTTPステータスが422 Unprocessable Entityであること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :active, admin: nil)
          user.create_reset_digest
          user.update!(reset_sent_at: 3.hours.ago)
          params = {
            user: {
              email: user.email,
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{user.reset_token}", params:)
          expect(response).to have_http_status(:unprocessable_entity)
        end

        example "エラーメッセージが返却されること" do
          user = FactoryBot.create(:user, email: "test@example.com", state: :active, admin: nil)
          user.create_reset_digest
          user.update!(reset_sent_at: 3.hours.ago)
          params = {
            user: {
              email: user.email,
              password: "password",
              password_confirmation: "password"
            }
          }
          put("/password_resets/#{user.reset_token}", params:)
          error_message = I18n.t("errors.display_message.password_reset.expired")
          result = JSON.parse(response.body, { symbolize_names: true })
          expect(result[:error][:message]).to eq error_message
        end
      end
    end
  end
end
