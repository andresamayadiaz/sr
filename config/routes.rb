Soyreceptor::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}

  match 'webhook' => 'webhook#conekta', :via => [:post] 
   
  devise_scope :user do
    authenticated :user do
      root 'home#index', as: :authenticated_root
      post 'upload_comprobante', to: 'home#upload_comprobante'
      post 'add_tag', to: 'home#add_tag', ad: :add_tag
      post 'remove_tag', to: 'home#remove_tag', ad: :remove_tag
      get 'emitidos', to: 'home#emitidos'
      get 'recibidos', to: 'home#recibidos'
      get 'otros', to: 'home#otros'
      get 'alertas', to: 'home#alertas'
      get 'vistadealertas', to: 'home#view_single_notification'
      get 'buscar', to: 'home#buscar'
      get 'buscardealertas', to: 'home#buscar_de_alertas'
      get 'tags', to: 'home#tags'
      get 'comprobante/:id', to: 'home#comprobante', as: :comprobante
      get 'cbb/:id', to: 'home#cbb', as: :cbb
      get 'upgrade', to: 'home#upgrade'
      get 'downgrade', to: 'home#downgrade'
      get 'new_payment', to: 'home#new_payment'
      get 'eliminar', to: 'home#eliminar'
      get 'comprobante/xml/:id', to: 'home#download_xml'
      get 'comprobante/pdf/:id', to: 'home#download_pdf'
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
      patch 'register_payment', to: 'users#register_payment'
    end
  end
  
end
