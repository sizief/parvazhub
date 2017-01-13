Rails.application.routes.draw do
  get '/about-us', to:'static_pages#about_us'

  get '/search', to:'search#search_proccess'
  get '/test', to:'search#test'
  
  resources :routes

  root 'search#flight'


end
