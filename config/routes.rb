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
      patch 'update_generales', to: 'users#update_generales'
      patch 'update_notificaciones', to: 'users#update_notificaciones'
      post 'update_logo', to: 'users#update_logo'
    end
  end
  
  #resources :users
  
  
end