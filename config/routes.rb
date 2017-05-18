Rails.application.routes.draw do
  namespace :admin do
    get 'dashboard/user_search_history'
  end

  get '/about-us', to:'static_pages#about_us'

  get '/search', to:'search#search_proccess'
  get '/test', to:'search#test'

  get '/flight-prices/:id', to: 'search#flight_prices', as: 'flight-prices' #, :defaults => { :format => 'js' }
  resources :routes

  root 'search#flight'
end
