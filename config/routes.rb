Rails.application.routes.draw do
	require 'sidekiq/web'
	require 'sidekiq-scheduler/web'
	
	resources :routes

	namespace :admin do
		get 'dashboard/user_search_history'
		get 'dashboard/search_history'
		get 'dashboard/supplier_control'
		post 'dashboard/supplier_control', to:'dashboard#update_supplier'

		mount Sidekiq::Web => '/sidekiq'
	end

	get '/about_us', to:'static_pages#about_us'

	get '/flights', to:'search_result#search', as: 'flights'

	get '/flight-prices/:id', to: 'search_result#flight_prices', as: 'flight-prices' #, :defaults => { :format => 'js' }

	get 'home/index'
	get 'static_pages/about_us'
	
	get 'city/:city_name', to: 'city_page#index', as: 'city_page'
     
	root 'home#index'
end