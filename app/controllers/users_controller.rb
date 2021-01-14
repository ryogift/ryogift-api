class UsersController < ApplicationController
  before_action :logged_in_user?, except: :create
  before_action :admin?, only: [:index, :destroy, :lock, :unlock]

  # GET /users
  def index
    users_json = User.list_json
    render json: lower_camelize_keys(users_json)
  end

  # GET /users/:id
  def show
    user = User.find_by(id: params[:id])
    return render json: {}, status: :unauthorized unless current_user?(user)

    user_json = user.to_display_json
    render json: lower_camelize_keys(user_json)
  end

  # POST /users
  def create
    user = User.new(user_params)

    if user.save
      user.send_activation_email
      user_json = user.to_display_json
      render(json: lower_camelize_keys(user_json),
             status: :created, location: user)
    else
      render json: lower_camelize_keys(user.errors.as_json), status: :unprocessable_entity
    end
  end

  # PUT /users/:id
  def update
    user = User.find(params[:id])
    return render json: {}, status: :unauthorized unless current_user?(user)

    if user.update(user_params)
      user_json = user.to_display_json
      render json: lower_camelize_keys(user_json)
    else
      render json: lower_camelize_keys(user.errors.as_json), status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    user = User.find(params[:id])
    user.destroy!
  end

  # PUT /users/:id/lock
  def lock
    user = User.find(params[:id])
    user.lock
    render json: {}
  end

  # PUT /users/:id/unlock
  def unlock
    user = User.find(params[:id])
    user.unlock
    render json: {}
  end

  # PUT /users/:id/update_password
  def update_password
    user = User.find(params[:id])
    return render json: {}, status: :unauthorized unless current_user?(user)

    if user_params[:password].blank? || user_params[:password_confirmation].blank?
      error_message = I18n.t("errors.display_message.password_reset.blank")
      render json: response_error(error_message), status: :unprocessable_entity
    elsif user.update(user_params)
      user_json = user.to_display_json
      render json: lower_camelize_keys(user_json)
    else
      render json: lower_camelize_keys(user.errors.as_json), status: :unprocessable_entity
    end
  end

  private

  # 信頼できるパラメータ「ホワイトリスト」のみを許可する。
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
