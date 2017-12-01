Rails.application.routes.draw do
  devise_for :users
	require 'sidekiq/web'
	require 'sidekiq-scheduler/web'
	
	resources :routes

	namespace :admin do
		get 'dashboard', to:'dashboard#index'
		get 'dashboard/user_search_history'
		get 'dashboard/user_search_stat'
		get 'dashboard/search_history'
		get 'dashboard/supplier_control'
		get 'dashboard/price_alert'
		get 'dashboard/redirect'
		get 'dashboard/review'
		post 'dashboard/supplier_control', to:'dashboard#update_supplier'

		mount Sidekiq::Web => '/sidekiq'
	end
	
	get 'home/index'
	
	get '/flight_search', to:'search_result#flight_search', as: 'flight_search'
    
	get '/flights/', to: 'city_page#flight', as: 'flight_page'
	get '/flights/:origin_name-:destination_name-:month/', to: 'city_page#route', as: 'route_by_month_page'	
	get '/flights/:origin_name-:destination_name/', to: 'city_page#route', as: 'route_page'
	get '/flights/:origin_name-:destination_name/:date', to:'search_result#search', as: 'flight_result'
	get '/flights/:origin_name-:destination_name/:date/:id', to: 'search_result#flight_prices', as: 'flight_prices'
	
	get 'redirect/:origin_name-:destination_name/:date/:flight_id/:flight_price_id/:channel', to: 'redirect#redirect', as: 'redirect'

	post 'notification/price_alert_register', to: 'notification#price_alert_register', as: 'price_alert_register'
	
	get '/about_us', to:'static_pages#about_us'
	get 'static_pages/about_us'

	get '/beta/telegram/update', to: 'telegram#update'
	post '/beta/telegram/webhook', to: 'telegram#webhook'

	get '/review/', to: 'review#index', as: 'review_index_page'	
	get '/review/:property_name', to: 'review#property_reviews', as: 'property_page'
	post '/review', to: 'review#register', as: 'register_review'

	get '/api/city_prefetch_suggestion', to: 'api#city_prefetch_suggestion', as: 'api_city_prefetch_suggestion'
	get '/api/city_suggestion/:query', to: 'api#city_suggestion', as: 'api_city_suggestion'
	get '/api/service-test/', to: 'api#service_test', as: 'service_test'
	
	
	get '/flight-prices/:id', to: redirect('/', status: 302) #, to: 'search_result#flight_prices', as: 'flight-prices-ajax' #, :defaults => { :format => 'js' }
	
	root 'home#index'
end