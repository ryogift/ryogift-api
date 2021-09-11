require "rails_helper"

RSpec.describe "Users", type: :request do
  describe "/" do
    example "HTTPステータスが200 OKであること" do
      get "/"
      expect(response).to have_http_status(:ok)
    end

    example "JSONデータが取得できること" do
      get "/"
      result = JSON.parse(response.body, { symbolize_names: true })
      expect(result[:top]).to eq "Ryo.gift API"
    end
  end
end
