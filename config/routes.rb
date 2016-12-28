Rails.application.routes.draw do
  post '/search', to:'search#search_proccess'
  get '/test', to:'search#test'
  root 'search#flight'
end
