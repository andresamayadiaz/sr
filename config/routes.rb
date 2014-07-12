Soyreceptor::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}
  
  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
      post 'upload_comprobante', to: 'home#upload_comprobante'
      post 'add_tag', to: 'home#add_tag', ad: :add_tag
      post 'remove_tag', to: 'home#remove_tag', ad: :remove_tag
      get 'emitidos', to: 'home#emitidos'
      get 'recibidos', to: 'home#recibidos'
      get 'comprobante/:id', to: 'home#comprobante', as: :comprobante
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
  
end