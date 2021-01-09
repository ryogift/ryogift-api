require "rails_helper"

RSpec.describe "Posts", type: :request do
  describe "/posts" do
    before do
      @user = FactoryBot.create(:user)
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
        { user_id: @user.id }
      )
      @post1 = FactoryBot.create(:post, user: @user, content: "test1")
      @post2 = FactoryBot.create(:post, user: @user, content: "test2")
    end

    describe "GET" do
      example "HTTPステータスが200 OKであること" do
        get "/posts"
        expect(response).to have_http_status(:ok)
      end

      example "ユーザーの投稿一覧が取得できること" do
        get "/posts"
        posts = JSON.parse(response.body, { symbolize_names: true })
        expect(posts).to eq(
          [
            {
              id: @post1.id, userName: @post1.user_name, content: @post1.content, state: @post1.state,
              displayUpdatedAt: @post1.display_updated_at, displayPublishedAt: @post1.display_published_at
            },
            {
              id: @post2.id, userName: @post2.user_name, content: @post2.content, state: @post2.state,
              displayUpdatedAt: @post2.display_updated_at, displayPublishedAt: @post2.display_published_at
            }
          ]
        )
      end
    end

    describe "POST" do
      example "ユーザーの投稿が作成できること" do
        params = {
          post: {
            content: "test",
            state: "private"
          }
        }
        post "/posts", params: params
        expect(response).to have_http_status(:created)
      end

      example "バリデーションエラー時にHTTPステータスが422 Unprocessable Entityであること" do
        params = {
          post: {
            content: "",
            state: "private"
          }
        }
        post "/posts", params: params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      example "バリデーションエラー時にエラーメッセージが返却されること" do
        params = {
          post: {
            content: "",
            state: "private"
          }
        }
        post "/posts", params: params
        expect(JSON.parse(response.body)["content"]).to eq(I18n.t("errors.messages.blank"))
      end
    end
  end

  describe "/posts/:id" do
    before do
      @user = FactoryBot.create(:user)
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(
        { user_id: @user.id }
      )
      @post1 = FactoryBot.create(:post, user: @user, content: "test1")
    end

    describe "GET" do
      example "HTTPステータスが200 OKであること" do
        get "/posts/#{@post1.id}"
        expect(response).to have_http_status(:ok)
      end

      example "ユーザーの投稿情報が取得できること" do
        get "/posts/#{@post1.id}"
        post = JSON.parse(response.body, { symbolize_names: true })
        expect(post).to eq(
          {
            id: @post1.id, userName: @post1.user_name, content: @post1.content, state: @post1.state,
            displayUpdatedAt: @post1.display_updated_at, displayPublishedAt: @post1.display_published_at
          }
        )
      end
    end

    describe "PUT" do
      example "HTTPステータスが200 OKであること" do
        put "/posts/#{@post1.id}", params: { post: { content: "aaa" } }
        expect(response).to have_http_status(:ok)
      end

      example "ユーザーの投稿情報が更新できること" do
        put "/posts/#{@post1.id}", params: { post: { content: "aaa" } }
        post = JSON.parse(response.body, { symbolize_names: true })
        expect(post[:content]).to eq "aaa"
      end

      example "バリデーションエラー時にHTTPステータスが422 Unprocessable Entityであること" do
        put "/posts/#{@post1.id}", params: { post: { content: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      example "バリデーションエラー時にエラーメッセージが返却されること" do
        put "/posts/#{@post1.id}", params: { post: { content: "" } }
        expect(JSON.parse(response.body)["content"]).to eq(I18n.t("errors.messages.blank"))
      end

      example "ユーザーの投稿情報ではない場合にHTTPステータスが404 Not Foundであること" do
        other_user = FactoryBot.create(:user, email: "other@example.com")
        post2 = FactoryBot.create(:post, user: other_user, content: "test1")
        put "/posts/#{post2.id}", params: { post: { content: "" } }
        expect(response).to have_http_status(:not_found)
      end
    end

    describe "DELETE" do
      example "HTTPステータスが204 No Contentであること" do
        delete "/posts/#{@post1.id}"
        expect(response).to have_http_status(:no_content)
      end

      example "ユーザーの投稿情報ではない場合にHTTPステータスが404 Not Foundであること" do
        other_user = FactoryBot.create(:user, email: "other@example.com")
        post2 = FactoryBot.create(:post, user: other_user, content: "test1")
        delete "/posts/#{post2.id}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
