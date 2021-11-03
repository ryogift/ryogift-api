require "rails_helper"

RSpec.describe Post, type: :model do
  example "有効なファクトリを持つこと" do
    expect(FactoryBot.build(:post)).to be_valid
  end

  describe "validates" do
    example "投稿内容が必須であること" do
      post = FactoryBot.build(:post, content: "     ")
      post.valid?
      expect(post.errors[:content]).to include I18n.t("errors.messages.blank")
    end

    example "投稿内容が1000文字以内であること" do
      post = FactoryBot.build(:post, content: "a" * 1001)
      post.valid?
      expect(post.errors[:content]).to include I18n.t("errors.messages.too_long", count: 1000)
    end
  end

  describe "display_updated_at" do
    example "表示用の更新日が返されること" do
      post = FactoryBot.build_stubbed(:post)
      expect(post.display_updated_at).to eq post.updated_at.strftime("%Y/%m/%d %T")
    end

    example "更新日がnullの場合に空文字が返されること" do
      post = FactoryBot.build(:post)
      expect(post.display_updated_at).to eq ""
    end
  end

  describe "display_published_at" do
    example "表示用の公開日が返されること" do
      post = FactoryBot.build(:post, published_at: Time.zone.now)
      expect(post.display_published_at).to eq post.published_at.strftime("%Y/%m/%d %T")
    end

    example "公開日がnullの場合に空文字が返されること" do
      post = FactoryBot.build(:post)
      expect(post.display_published_at).to eq ""
    end
  end

  describe "list_json" do
    example "投稿一覧がJSON形式で取得できること" do
      user = FactoryBot.create(:user)
      post1 = FactoryBot.create(:post, user: user, content: "test1")
      post2 = FactoryBot.create(:post, user: user, content: "test2")
      posts_json = Post.list_json.map(&:deep_symbolize_keys)
      expect(posts_json).to eq [
        {
          id: post2.id, content: post2.content, user_name: user.name,
          display_updated_at: post2.display_updated_at, display_published_at: post2.display_published_at
        },
        {
          id: post1.id, content: post1.content, user_name: user.name,
          display_updated_at: post1.display_updated_at, display_published_at: post1.display_published_at
        }
      ]
    end

    example "投稿一覧が0件の場合に空の配列が返されること" do
      posts_json = Post.list_json
      expect(posts_json).to eq []
    end
  end

  describe "user_list_json" do
    example "ユーザーの投稿一覧がJSON形式で取得できること" do
      user = FactoryBot.create(:user)
      post1 = FactoryBot.create(:post, user: user, content: "test1")
      post2 = FactoryBot.create(:post, user: user, content: "test2")
      posts_json = Post.user_list_json(user_id: user.id).map(&:deep_symbolize_keys)
      expect(posts_json).to eq [
        {
          id: post2.id, content: post2.content, user_name: user.name,
          display_updated_at: post2.display_updated_at, display_published_at: post2.display_published_at
        },
        {
          id: post1.id, content: post1.content, user_name: user.name,
          display_updated_at: post1.display_updated_at, display_published_at: post1.display_published_at
        }
      ]
    end

    example "ユーザーの投稿一覧が0件の場合に空の配列が返されること" do
      user = FactoryBot.build_stubbed(:user)
      posts_json = Post.user_list_json(user_id: user.id)
      expect(posts_json).to eq []
    end
  end

  describe "find_post_json" do
    example "ユーザーの投稿がJSON形式で取得できること" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user, content: "test1")
      post_json = Post.find_post_json(post_id: post.id).deep_symbolize_keys
      expect(post_json).to eq(
        {
          id: post.id, content: post.content, user_name: user.name,
          display_updated_at: post.display_updated_at, display_published_at: post.display_published_at
        }
      )
    end

    example "ユーザーの投稿が見つからない場合に結果が空であること" do
      post_json = Post.find_post_json(post_id: -1)
      expect(post_json.blank?).to eq true
    end
  end

  describe "find_user_post_json" do
    example "ユーザーの投稿がJSON形式で取得できること" do
      user = FactoryBot.create(:user)
      post = FactoryBot.create(:post, user: user, content: "test1")
      post_json = Post.find_user_post_json(user_id: user.id, post_id: post.id).deep_symbolize_keys
      expect(post_json).to eq(
        {
          id: post.id, content: post.content, user_name: user.name,
          display_updated_at: post.display_updated_at, display_published_at: post.display_published_at
        }
      )
    end

    example "ユーザーの投稿が見つからない場合に結果が空であること" do
      user = FactoryBot.build_stubbed(:user)
      post_json = Post.find_user_post_json(user_id: user.id, post_id: -1)
      expect(post_json.blank?).to eq true
    end
  end
end
