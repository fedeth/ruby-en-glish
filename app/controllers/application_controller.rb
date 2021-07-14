class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  def healthcheck
    render plain: 'OK'
  end
end
