Rails.application.routes.draw do
  post '/search', to:'search#save_result'
  get '/test', to:'search#test'
  root 'search#flight'
end
