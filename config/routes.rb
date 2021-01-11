Rails.application.routes.draw do
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"
  resources :users do
    member do
      put "lock"
      put "unlock"
    end
  end
  resources :account_activations, only: [:edit]
  resources :password_resets, only: [:create, :update]
  resources :posts
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
