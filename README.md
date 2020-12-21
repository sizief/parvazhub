[![Build Status](https://travis-ci.org/sizief/parvazhub.svg?branch=master)](https://travis-ci.org/sizief/parvazhub)  
  
# PARVAZHUB
[PARVAZHUB](https://parvazhub.com) is a domestic Iranian flight metasearch website.  
  
## Last status
Providers are blocking Parvazhub constantly. We have two optins:
- Search providers in the browser, client side. This is not working for most websites because of CORS. See my last try at `webpacker` branch.
- Search through proxies. This increases costs. Also causes slow search.
- last backup of passenger's review is [here](./backup_reviews.csv)

## Development 
- You need Ruby 2.6.5, Postgress, Redis
- `cp .env.example .env` 
- You need to get end point URLs from suppliers and update the env file (or ask me)
- `bundle`
- `bundle exec rails db:setup`, `bundle exec rails db:seed`
- `bundle exec rails s` or `foreman start` 
- `bundle exec rails test`

## Helpers
To search on console:  
```
x=Suppliers::Ghasedak.new(origin: "thr",destination: "mhd",date: (Date.today+1).to_s,timeout: 10,search_history: SearchHistory.last,route: Route.find_by(origin: origin, destination: destination),search_flight: SearchFlightId.last,supplier_name: "flightio")
x.search_supplier
x.register_request # for the ones that has two level RQ/RS
```

Grep  
`grep -r proxy ./ --exclude-dir={node_modules,public,vendor,log,coverage} --exclude=tags`

## Production
Use `forman start` in `/var/www/parvazhub` to see output log. Also a puma service is availale and running in bckground: `sudo systemctl start/stop/restart parvazhub.target`
  
For login go to `/users/sign_in`, then for admin access grant access by doing `user.role= :admin` on rails console.  
To see and store logs in production, uncomment `config/puma.rb` log line.

For console do `bundle exec rails c -e production` in /var/www/parvazhub/current
## TODO
- proxies
- clean seeds
- community for reviewers

## Copyright
Do whatever you want. Just don't harm people.
