class PostsController < ApplicationController
  # GET /posts
  def index
    posts_json = Post.list_json
    render json: lower_camelize_keys(posts_json)
  end

  # GET /posts/:id
  def show
    post_json = Post.find_post_json(post_id: params[:id])
    render json: lower_camelize_keys(post_json)
  end
end
