OneclickRefernet::Engine.routes.draw do
  
  resources :categories, only: [:index]
  get 'categories/:code' => 'categories#show'
  
  resources :sub_categories, only: [:index]
  get 'sub_categories/:code' => 'sub_categories#show'

  resources :sub_sub_categories, only: [:index]
  get 'sub_sub_categories/:code' => 'sub_sub_categories#show'
  
  resources :services, only: [:index, :show]
  get 'services/details' => 'services#show'
  
  get 'search' => 'search#search'
  
end
