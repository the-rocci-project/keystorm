Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v3 do
    namespace :auth do
      resources :projects, only: [:index]
      resources :federation, only: [] do
        post 'oidc', on: :collection
        post 'voms', on: :collection
      end
      resources :tokens, only: [:create], constraints: ->(_r) { nil }
      resources :tokens, only: [:create], controller: 'local', constraints: ->(_r) { 'x' }
    end
  end
end
