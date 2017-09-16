Rails.application.routes.draw do
  devise_for :users
	require 'sidekiq/web'
	require 'sidekiq-scheduler/web'
	
	resources :routes

	namespace :admin do
		get 'dashboard', to:'dashboard#index'
		get 'dashboard/user_search_history'
		get 'dashboard/search_history'
		get 'dashboard/supplier_control'
		get 'dashboard/price_alert'
		get 'dashboard/redirect'
		post 'dashboard/supplier_control', to:'dashboard#update_supplier'

		mount Sidekiq::Web => '/sidekiq'
	end
	
	get 'home/index'
	
	get '/flight_search', to:'search_result#flight_search', as: 'flight_search'
    
	get '/flights/', to: 'city_page#flight', as: 'flight_page'
	get '/flights/:origin_name-:destination_name/', to: 'city_page#route', as: 'route_page'
	get '/flights/:origin_name-:destination_name/:date', to:'search_result#search', as: 'flight_result'
	get '/flights/:origin_name-:destination_name/:date/:id', to: 'search_result#flight_prices', as: 'flight-prices'
	
	get '/flight-prices/:id', to: 'search_result#flight_prices', as: 'flight-prices-ajax' #, :defaults => { :format => 'js' }
	get 'redirect/:channel/:flight_price_id', to: 'redirect#redirect', as: 'redirect'

	post 'notification/price_alert_register', to: 'notification#price_alert_register', as: 'price_alert_register'
	
	get '/about_us', to:'static_pages#about_us'
	get '/cheap-flights', to:'static_pages#cheap_flights'
	get 'static_pages/about_us'

	get '/beta/telegram/update', to: 'telegram#update'
	post '/beta/telegram/webhook', to: 'telegram#webhook'
	 
	root 'home#index'
end