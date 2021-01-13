class PostsController < ApplicationController
  before_action :logged_in_user?

  # GET /posts
  def index
    posts_json = Post.list_json(user_id: current_user)
    render json: lower_camelize_keys(posts_json)
  end

  # GET /posts/:id
  def show
    post_json = Post.find_user_post_json(user_id: current_user.id, post_id: params[:id])
    render json: lower_camelize_keys(post_json)
  end

  # POST /posts
  def create
    post = Post.new(post_params)
    post.user_id = current_user.id
    if post.save
      render(json: lower_camelize_keys(post.as_json),
             status: :created, location: post)
    else
      render json: lower_camelize_keys(post.errors.as_json), status: :unprocessable_entity
    end
  end

  # PUT /posts/:id
  def update
    post = Post.find_by(user_id: current_user.id, id: params[:id])
    if post.blank?
      render json: {}, status: :not_found
    elsif post.update(post_params)
      render json: lower_camelize_keys(post.as_json)
    else
      render json: lower_camelize_keys(post.errors.as_json), status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    post = Post.find_by(user_id: current_user.id, id: params[:id])
    if post.blank?
      render json: {}, status: :not_found
    else
      post.destroy!
    end
  end

  private

  # 信頼できるパラメータ「ホワイトリスト」のみを許可する。
  def post_params
    params.require(:post).permit(:content, :state)
  end
end
