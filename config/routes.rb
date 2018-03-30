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
    
	get '/flights/', to: 'route#flight', as: 'flight_page'
	get '/flights/:origin_name-:destination_name-:month/', to: 'route#route', as: 'route_by_month_page'	
	get '/flights/:origin_name-:destination_name/', to: 'route#route', as: 'route_page'
	get '/flights/:origin_name-:destination_name/:date', to:'search_result#search', as: 'flight_result'
	get '/flights/:origin_name-:destination_name/:date/:id', to: 'search_result#flight_prices', as: 'flight_prices'
	
	get 'redirect/:origin_name-:destination_name/:date/:flight_id/:flight_price_id/:channel', to: 'redirect#redirect', as: 'redirect'

	post 'notification/price_alert_register', to: 'notification#price_alert_register', as: 'price_alert_register'
	
	get '/us', to:'static_pages#us', as: "us"
	get '/our-service', to:'static_pages#our_service', as: 'our_service'
	get '/policy', to:'static_pages#policy', as: 'policy'



	get '/beta/telegram/update', to: 'telegram#update'
	post '/beta/telegram/webhook', to: 'telegram#webhook'

	get '/airline-review/', to: 'review#airline_index', as: 'airline_review_index_page'	
	get '/airline-review/:property_name', to: 'review#airline_reviews', as: 'airline_review_page'
	get '/supplier-review/', to: 'review#supplier_index', as: 'supplier_review_index_page'	
	get '/supplier-review/:property_name', to: 'review#supplier_reviews', as: 'supplier_review_page'
	post '/review', to: 'review#register', as: 'register_review'

	get '/api/v1/city_prefetch_suggestion', to: 'api#city_prefetch_suggestion', as: 'api_city_prefetch_suggestion'
	get '/api/v1/city_suggestion/:query', to: 'api#city_suggestion', as: 'api_city_suggestion'
	get '/api/v1/service-test/', to: 'api#service_test', as: 'service_test'
	get '/api/v1/flights/', to: 'api#flights', as: 'api_flights'
	get '/api/v1/suppliers/', to: 'api#suppliers', as: 'api_suppliers'

	get '/flight-prices/:id', to: redirect('/', status: 301) #, to: 'search_result#flight_prices', as: 'flight-prices-ajax' #, :defaults => { :format => 'js' }
	get '/review/', to: redirect('/airline-review/', status: 301)
	get '/review/:property_name', to: redirect('/airline-review/%{property_name}', status: 301)


	root 'home#index'
end