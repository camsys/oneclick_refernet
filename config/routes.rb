OneclickRefernet::Engine.routes.draw do
  
  resources :categories, only: [:index]
  resources :sub_categories, only: [:index]
  resources :sub_sub_categories, only: [:index]
  
  resources :services, only: [:index]
  
end
