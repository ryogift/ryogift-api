require "rails_helper"

RSpec.describe UsersController, type: :controller do
  example "セッション切れの場合にcookiesに設定しているuser_idより、再設定すること" do
    admin_user = FactoryBot.create(:user, admin: true)
    cookies.signed[:user_id] = admin_user.id
    get :index
    expect(session[:user_id]).to eq admin_user.id
  end
end
