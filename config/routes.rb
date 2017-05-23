Rails.application.routes.draw do
	require 'sidekiq/web'
	require 'sidekiq-scheduler/web'
	
	namespace :admin do
		get 'dashboard/user_search_history'
		get 'dashboard/search_history'
		mount Sidekiq::Web => '/sidekiq'
	end

	get '/about-us', to:'static_pages#about_us'

	get '/search', to:'search#search_proccess'
	get '/test', to:'search#test'

	get '/flight-prices/:id', to: 'search#flight_prices', as: 'flight-prices' #, :defaults => { :format => 'js' }
	resources :routes

	root 'search#flight'
end
