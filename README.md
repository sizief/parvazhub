# How to install and run  
  
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

  
## how to run  
run sidekiq proccess then go to localhost:3000/sidekiq  
bundle exec sidekiq  
  
### run redis GUI then go to localhost:8081  
redis-commander  
  
### run redis  
redis-server  

### how to install pgresql  
install pgresql on ubuntu, create user and password: tutorial here: https://www.digitalocean.com/community/tutorials/how-to-use-postgresql-with-your-ruby-on-rails-application-on-ubuntu-14-04  
sudo -u postgres createuser -s pguser  
sudo -u postgres psql  
\password pguser  
  
  
## 3rdpart softwares  
https://github.com/mdehoog/Semantic-UI-Calendar
https://github.com/doabit/semantic-ui-sass
https://semantic-ui.com/
  