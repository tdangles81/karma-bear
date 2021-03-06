Rails.application.routes.draw do
  root 'main#index'
  get  'home', to: 'main#index'

  get 'users/:username', to: 'givers#show', as: :giver

  get 'charities/apply', to: 'charities#verification'

  devise_for :managers, :controllers => { sessions: "managers_sessions" }
  devise_for :givers, :controllers => { :omniauth_callbacks => "givers_omniauth_callbacks" }

  namespace :manager do
    root 'charities#show'

    get 'mail', to: 'mail#show'
    post 'mail/followers', to: 'mail#followers'

    resources :charities,         only: [:show] do
      resources :givers,          only: [:index, :show]
      resources :events do
        resources :givers,        only: [:index, :show]
        resources :registrations, only: [:index, :show, :update, :destroy]
      end
      resources :needs do
        resources :givers,        only: [:index, :show]
        resources :donations,     only: [:index, :show, :update, :destroy]
      end
    end
  end

  resources :charities,         only: [:index, :show] do
    resources :subscriptions,   only: [:create, :destroy]
    resources :events,          only: :show do
      resources :registrations, except: :index
    end
    resources :needs,           only: :show do
      resources :donations,     except: :index
    end
  end

  namespace :api, defaults: { format: :json } do
    get 'charities',      to: 'api#charities'
    post 'search',        to: 'api#search'
    post 'auth/verify',   to: 'auth#verify'
    post 'auth/giver',    to: 'auth#giver'
    post 'auth/charity',  to: 'auth#charity'
    post 'auth/follow',   to: 'auth#follow'
    post 'auth/donate',   to: 'auth#donate'
    post 'auth/register', to: 'auth#register'

    get 'auth/test', to: 'auth#test'
  end

  mount ActionCable.server => '/cable'
end
