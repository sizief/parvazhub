# 3rdpart softwares

https://bootstrap-datepicker.readthedocs.io/en/latest/

#run sidekiq proccess then go to localhost:3000/sidekiq
bundle exec sidekiq

#run redis GUI then go to localhost:8081
redis-commander

#run redis
redis-server

# install pgresql on ubuntu, create user and password: tutorial here: https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-14-04

sudo -u postgres createuser -s pguser
sudo -u postgres psql
\password pguser