require "rails_helper"

RSpec.describe "Posts", type: :request do
  describe "/posts" do
    before do
      @user = FactoryBot.create(:user)
      @user2 = FactoryBot.create(:user, email: "test@example.com", admin: false)
      @post1 = FactoryBot.create(:post, user: @user, content: "test1")
      @post2 = FactoryBot.create(:post, user: @user, content: "test2")
      @post3 = FactoryBot.create(:post, user: @user2, content: "test3")
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
              id: @post3.id, userName: @post3.user_name, content: @post3.content,
              displayUpdatedAt: @post3.display_updated_at, displayPublishedAt: @post3.display_published_at
            },
            {
              id: @post2.id, userName: @post2.user_name, content: @post2.content,
              displayUpdatedAt: @post2.display_updated_at, displayPublishedAt: @post2.display_published_at
            },
            {
              id: @post1.id, userName: @post1.user_name, content: @post1.content,
              displayUpdatedAt: @post1.display_updated_at, displayPublishedAt: @post1.display_published_at
            }
          ]
        )
      end
    end
  end

  describe "/posts/:id" do
    before do
      @user = FactoryBot.create(:user)
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
            id: @post1.id, userName: @post1.user_name, content: @post1.content,
            displayUpdatedAt: @post1.display_updated_at, displayPublishedAt: @post1.display_published_at
          }
        )
      end
    end
  end
end
