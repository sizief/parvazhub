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
		post 'dashboard/supplier_control', to:'dashboard#update_supplier'

		mount Sidekiq::Web => '/sidekiq'
	end

	get '/about_us', to:'static_pages#about_us'

	get '/flight_search', to:'search_result#flight_search', as: 'flight_search'

	get '/flights/:origin_name/:destination_name/:date', to:'search_result#search'

	get '/flight-prices/:id', to: 'search_result#flight_prices', as: 'flight-prices' #, :defaults => { :format => 'js' }

	get 'home/index'

	get 'static_pages/about_us'
	
	get 'city/:city_name', to: 'city_page#index', as: 'city_page'

	post 'notification/price_alert_register', to: 'notification#price_alert_register', as: 'price_alert_register'

	get 'redirect/:flight_price_id', to: 'redirect#redirect', as: 'redirect'
     
	root 'home#index'
end