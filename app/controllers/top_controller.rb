class TopController < ApplicationController
  def index
    render json: { top: "Ryo.gift API" }, status: :ok
  end
end
