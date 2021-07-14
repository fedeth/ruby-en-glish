Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', skip: [:omniauth_callbacks]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get 'test_logged_user', to: 'test#test_logged_user'
  get 'test_logged_user_bis', to: 'test#test_logged_user_bis'
end
