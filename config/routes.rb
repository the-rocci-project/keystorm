Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'discovery#index'

  namespace :v3 do
    root 'info#index'

    namespace :auth do
      resources :projects, only: [:index]
      resources :federation, only: [] do
        get 'oidc', on: :collection
        get 'voms', on: :collection
      end
      resources :tokens, only: [:create]
    end
  end
end
