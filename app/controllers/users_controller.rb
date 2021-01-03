class UsersController < ApplicationController
  # GET /users
  def index
    users = User.select(:id, :name, :email, :admin)
    render json: users
  end

  # GET /users/:id
  def show
    user = User.select(:id, :name, :email, :admin).find(params[:id])
    render json: user
  end

  # POST /users
  def create
    user = User.new(user_params)

    if user.save
      user.send_activation_email
      render(json: lower_camelize_keys(user.as_json(except: except)),
             status: :created, location: user)
    else
      render json: lower_camelize_keys(user.errors), status: :unprocessable_entity
    end
  end

  # PUT /users/:id
  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: lower_camelize_keys(user.as_json(except: except))
    else
      render json: lower_camelize_keys(user.errors), status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    user = User.find(params[:id])
    user.destroy!
  end

  private

  # 信頼できるパラメータ「ホワイトリスト」のみを許可する。
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def except
    [:password_digest, :remember_digest, :reset_digest, :activation_digest]
  end
end
