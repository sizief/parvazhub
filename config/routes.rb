Rails.application.routes.draw do
  post '/search', to:'search#results'
  get '/test', to:'search#test'
  root 'search#flight'
end
