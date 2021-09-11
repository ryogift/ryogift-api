Rails.application.routes.draw do
  root to: "top#index"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  get "client_user", to: "sessions#client_user"
  resources :users do
    member do
      put "lock"
      put "unlock"
      put "update_password"
    end
  end
  resources :account_activations, only: [:update]
  resources :password_resets, only: [:create, :update]
  resources :posts, only: [:index, :show]
  resources :user_posts
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
