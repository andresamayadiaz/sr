Soyreceptor::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}

  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
    end

    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  
  resource :user, only: [:edit] do
    collection do
      get 'perfil', to: 'users#perfil'
      patch 'perfil', to: 'users#perfil'
      patch 'update_password', to: 'users#update_password'
    end
  end
  
  #resources :users
  
  
end