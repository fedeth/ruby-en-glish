class TestController < ApplicationController
  before_action :authenticate_user!

  def test_logged_user
    render json: {
      data: {
        message: "foobar",
        user: current_user
      }
    }, status: 200
  end

  def test_logged_user_bis
    render json: {
      data: {
        message: "foobar bis",
        user: current_user,
      }
    }, status: 200
  end
end
