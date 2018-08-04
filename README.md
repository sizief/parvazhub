<a href="https://codeclimate.com/github/sizief/parvazhub/maintainability"><img src="https://api.codeclimate.com/v1/badges/82b1750afce7d8a317d0/maintainability" /></a>  
  
  
# PARVAZHUB
[PARVAZHUB](https://parvazhub.com) is a Flight meta search for Iranian Online Travel Agencies. It is written in Ruby on Rails.  

See [about us](https://parvazhub.com/us) page for more information (it's in Farsi)


## Run it on your local 
A. pull the repo  
B. copy .env.production.local and docker-compose.override.yml to root  
C. run docker-compose run app db:create db:migrate db:seed
D. run docker-compose build  
E. run docker-compose up  