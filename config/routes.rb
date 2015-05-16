Rails.application.routes.draw do
  root 'homes#index'
  devise_for :users, controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  # in case the oauth provider doesn't provide a verified email address
  match '/users/:id/finish_signup' => 'users#finish_signup', via: [:get, :patch], :as => :finish_signup

  resources :user_bad_words, only: [:create, :destroy]
  resources :bad_words, only: [:index, :create]


end
