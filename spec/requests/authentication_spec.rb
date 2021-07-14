require 'rails_helper'
require 'byebug'
include ActionController::RespondWith

JSON_HEADERS = { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

describe "Authentication flow", type: :request do
  context "user" do  
    
    before(:all) do
      
      confirmed_user = User.new(email: "created_user@test.example", password: "xxxxxxxxx")
      confirmed_user.skip_confirmation!
      confirmed_user.save

      post('http://localhost:3000/auth',
        params: {
          email: "test@test.example",
          password:"xxxxxxxxx",
          confirm_success_url: 'http://localhost:3000'
        }.to_json,
        headers: JSON_HEADERS
      )
      @registration_response = response
      confirmation_email_raw_body = ActionMailer::Base.deliveries[0].body.raw_source
      matches = /(?:href=")(?<confirmation_link>.*)(?:">)/.match(confirmation_email_raw_body)
      @confirmation_link = matches["confirmation_link"]
      uri = URI.parse(@confirmation_link)
      @confirmation_params = CGI::parse(uri.query)
    end

    it "performs a sign-up" do
      expect(@registration_response).to have_http_status(200)
    end

    it "performs a sign-in before confirmation" do
      post('http://localhost:3000/auth/sign_in',
        params: {
          email: "test@test.example",
          password:"xxxxxxxxx"
        }.to_json,
        headers: JSON_HEADERS
      )
      expect(response).to have_http_status(401)
    end

    it "confirms email link and retry a sign-in" do
      get("http://localhost:3000/auth/confirmation",
        params: {
          config: @confirmation_params["config"][0],
          confirmation_token: @confirmation_params["confirmation_token"][0],
          redirect_url: @confirmation_params["redirect_url"][0]
        }
      )
      expect(response).to have_http_status(302)
      expect(response.body).to match(/account_confirmation_success=true/)
      post('http://localhost:3000/auth/sign_in',
        params: {
          email: "test@test.example",
          password:"xxxxxxxxx"
        }.to_json,
        headers: JSON_HEADERS
      )
      expect(response).to have_http_status(200)
    end

    it "can't access to private methods" do
      get('http://localhost:3000/test_logged_user',
        headers: JSON_HEADERS
      )
      expect(response).to have_http_status(401)
    end

    it "can access to private methods" do
      login()
      auth_params = get_auth_params_from_login_response_headers(response)
      get('http://localhost:3000/test_logged_user',
        headers: JSON_HEADERS.merge(auth_params)
      )
      expect(response).to have_http_status(200)
      new_auth_params = get_auth_params_from_login_response_headers(response)
      get('http://localhost:3000/test_logged_user',
        headers: JSON_HEADERS.merge(new_auth_params)
      )
      expect(response).to have_http_status(200)
    end

    def login
      post('http://localhost:3000/auth/sign_in',
        params:  { email: "created_user@test.example", password: 'xxxxxxxxx' }.to_json,
        headers: JSON_HEADERS
      )
    end
  
    def get_auth_params_from_login_response_headers(response)
      client = response.headers['client']
      token = response.headers['access-token']
      expiry = response.headers['expiry']
      token_type = response.headers['token-type']
      uid = response.headers['uid']
  
      auth_params = {
        'access-token' => token,
        'client' => client,
        'uid' => uid,
        'expiry' => expiry,
        'token-type' => token_type
      }
      auth_params
    end

    after(:all) do
      User.destroy_all
    end
  end
end
