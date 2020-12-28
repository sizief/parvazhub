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
origin='mhd'; destination='thr';x=Suppliers::Ghasedak.new(origin: origin,destination: destination,date: (Date.today+1).to_s,search_history: SearchHistory.last,route: Route.find_by(origin: origin, destination: destination),supplier_name: "ghasedak")
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
For some reasons, `assets:precompile` does not add font folder to the public/assets. cp them manually from `/app/assets/fonts` to `/public/assets/fonts`

## TEST and CI/CD
Every commit on the master would triggers a [build](https://travis-ci.org/github/sizief/parvazhub/builds/). All .env values are also copied into Travis too. Then the copistrano app would deploy it to the server is tests passes.

## TODO
+ name | impact 10 high | how hard 10 high = overall
- proxies | 9 | 2 = 4.5
- fetch and show airplane type | 9 | 4 = 2.25
- add more prices - Chamedoon | 8 | 4 = 2
- show progress | 9 | 6 = 1.5
- add photos of the airplane by passengers | 7 | 5 = 1.4
- community for reviewers | 4 | 6 = 0.7
- remove allow origin for all in api | 0 | 1 = 0
- move codes from flight and flight price to collections
- update Airplane type
- Best price is not updated if threads runs out of timeout. post action for supplier search is never called if timeout is happens
- [x] add more prices - snaptripp | 8 | 4 = 2
- [x] fix the showing old data prices bug | 8 | 5 = 1.6
- [x] add more prices - Respina24 | 8 | 3 = 2.3

## Copyright
Do whatever you want. Just don't harm people.
