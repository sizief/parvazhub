Rails.application.routes.draw do
  namespace :admin do
    get 'dashboard/user_search_history'
  end

  get '/about-us', to:'static_pages#about_us'

  get '/search', to:'search#search_proccess'
  get '/test', to:'search#test'
  
  resources :routes

  root 'search#flight'


end
