[![Build Status](https://travis-ci.org/sizief/parvazhub.svg?branch=master)](https://travis-ci.org/sizief/parvazhub) [![Maintainability]  
  
# PARVAZHUB
[PARVAZHUB](https://parvazhub.com) is a domestic Iranian flight metasearch website.  
  
## Run it on your local 
- Install Ruby 2.6.5
- Install Postgress and sqlite
- `cp .env.example .env` 
- You need to get end point URLs from suppliers and update the env file
- `bundler`
- `bundle exec rails db:migrate`, `bundle exec rails db:seed`
- Install Redis
- `rails s` or `foreman start` 

## Production
Use `forman start` in `/var/www/parvazhub` to see output log. Also a puma service is availale and running in bckground: `sudo systemctl start/stop/restart parvazhub.target`
  
For login go to `/users/sign_in`, then for admin access grant access by doing `user.role= :admin` on rails console.  
To see and store logs in production, uncomment `config/puma.rb` log line.

## Copyright
<a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
