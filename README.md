# Instal with Docker  
A. pull the repo  
B. Install Postgres and create user  
C. copy .env.production.local and docker-compose.override.yml to root  
D. run docker-compose build  
E. run docker-compose up  
  
  
# How to install and run without docker  
  
## install    
A. install rbenv  
B. install ruby from rbenv  
C. install ruby dev sudo apt-get install ruby-dev  
D. install gem  
E. install bundler  
F. install rails  
G. install and create user for pgresql, see bottom for more help  
H. install nodejs
I. install build essential for unf_ext: apt-get install build-essential


### how to install pgresql  
install pgresql on ubuntu, create user and password: tutorial here: https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-14-04  
#### THIS IS FOR CREATING PG USER FOR ADMIN PURPOSE:  
sudo -u postgres createuser -s pguser  
sudo -u postgres psql  
\password pguser  
#### Create user for rails db, in pg console  
postgres=# create user "username" with password 'password';  
postgres=# create database "development" owner "username"; 
postgres=# ALTER USER username CREATEDB  
#### run create and migration for each environment  
rake db:create db:migrate RAILS_ENV=production  #if db is not exist  
rake db:migrate RAILS_ENV=production #if db exist  
#### If puma or unicorn freez    
delete tmp and run rake assets:precompile  
  
  
## 3rdpart softwares  
https://github.com/mdehoog/Semantic-UI-Calendar  
https://github.com/doabit/semantic-ui-sass  
https://semantic-ui.com/  
https://github.com/bkeepers/dotenv 
http://babakhani.github.io/PersianWebToolkit/doc/datepicker/#/quciksample/
Font? 

<a href="https://icons8.com/icon/5195/Dolphin">Dolphin icon credits</a>
  


  