Rails.application.routes.draw do
	require 'sidekiq/web'
	require 'sidekiq-scheduler/web'
	
	resources :routes

	namespace :admin do
		get 'dashboard/user_search_history'
		get 'dashboard/search_history'
		mount Sidekiq::Web => '/sidekiq'
	end

	get '/about-us', to:'static_pages#about_us'

	get '/search', to:'search_result#search_proccess'

	get '/flight-prices/:id', to: 'search_result#flight_prices', as: 'flight-prices' #, :defaults => { :format => 'js' }

	root 'home#index'
end