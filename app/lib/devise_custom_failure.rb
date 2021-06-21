class CustomFailureApp < Devise::FailureApp
  def respond
    # if request.format == :json
    #   json_error_response    
    # end
    json_error_response
  end

  def json_error_response
    self.status = 401
    self.content_type = "application/json"
    self.response_body = [ { message: "401 Unauthorized" } ].to_json
  end
end