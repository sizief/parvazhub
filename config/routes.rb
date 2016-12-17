Rails.application.routes.draw do
  post '/search', to:'search#results'
  root 'search#flight'
end
