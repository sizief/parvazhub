Rails.application.routes.draw do
  get '/about-us', to:'static_pages#about_us'

  post '/search', to:'search#search_proccess'
  get '/test', to:'search#test'
  root 'search#flight'
end
