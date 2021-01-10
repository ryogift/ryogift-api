class Post < ApplicationRecord
  belongs_to :user
  validates :content, presence: true, length: { maximum: 1000 }
  enum state: { private: 0, public: 1, ban: 2 }, _prefix: true

  delegate :name, to: :user, prefix: true

  def display_updated_at
    updated_at.present? ? updated_at.strftime(DISPLAY_DATETIME) : ""
  end

  def display_published_at
    published_at.present? ? published_at.strftime(DISPLAY_DATETIME) : ""
  end

  def self.list_json(user_id: nil)
    posts = includes(:user).where(user_id: user_id).order(:id)
    only = [:id, :user_name, :content, :display_updated_at, :state, :display_published_at]
    methods = [:user_name, :display_updated_at, :display_published_at]
    posts.as_json(methods: methods, only: only)
  end

  def self.find_user_post_json(user_id: nil, post_id: nil)
    post = includes(:user).find_by(user_id: user_id, id: post_id)
    only = [:id, :user_name, :content, :display_updated_at, :state, :display_published_at]
    methods = [:user_name, :display_updated_at, :display_published_at]
    post.as_json(methods: methods, only: only)
  end
end
