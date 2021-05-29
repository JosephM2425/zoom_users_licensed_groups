Rails.application.routes.draw do
  devise_for :admins
  resources :groups do 
    patch 'update_licenses', to: 'groups#update_licenses'
  end
  resources :users
  root 'groups#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
