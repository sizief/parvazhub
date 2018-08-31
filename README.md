[![Build Status](https://travis-ci.org/sizief/parvazhub.svg?branch=master)](https://travis-ci.org/sizief/parvazhub) [![Maintainability](https://api.codeclimate.com/v1/badges/82b1750afce7d8a317d0/maintainability)](https://codeclimate.com/github/sizief/parvazhub/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/82b1750afce7d8a317d0/test_coverage)](https://codeclimate.com/github/sizief/parvazhub/test_coverage)
  
  
# PARVAZHUB
[PARVAZHUB](https://parvazhub.com) is a Flight meta search for Iranian Online Travel Agencies. It is written in Ruby on Rails.  

See [about us](https://parvazhub.com/us) page for more information (it's in Farsi)


## Run it on your local 
A. pull the repo  
B. copy .env.production.local and docker-compose.override.yml to root  
C. `run docker-compose & run app db:create db:migrate db:seed`
D. `run docker-compose build`  
E. `run docker-compose up`  

  
Or simply run `foreman start`

## Copyright
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.