Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  namespace :v3 do
    namespace :auth do
      resources :projects, only: [:index]
      resources :federation, only: [] do
        get 'oidc', on: :collection
        get 'voms', on: :collection
      end
      resources :tokens, only: [:create], constraints: RoutingConstraints::TokensConstraint.new('token')
      resources :tokens, only: [], controller: 'local', constraints: RoutingConstraints::TokensConstraint.new('password')
      resources :tokens, only: [:create],
                         controller: 'garbage',
                         constraints: RoutingConstraints::GarbageConstraint.new(%w[token password])
    end
  end
end
