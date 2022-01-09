require "rails_helper"

RSpec.describe UsersController, type: :controller do
  example "セッション切れの場合にcookiesに設定しているuser_idより、再設定すること" do
    admin_user = FactoryBot.create(:user, admin: true)
    session = { user_id: nil }
    session.class_eval { def enabled?; true; end }
    session.class_eval { def loaded?; true; end }
    allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session)
    cookies.signed[:user_id] = admin_user.id
    get :index
    expect(session[:user_id]).to eq admin_user.id
  end
end
