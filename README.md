# PARVAZHUB
[PARVAZHUB](https://parvazhub.com) is a domestic Iranian flight metasearch website.

## Helpers
To search on console:
```
origin='mhd'; destination='thr';x=Suppliers::Ghasedak.new(origin: origin,destination: destination,date: (Date.today+1).to_s,search_history: SearchHistory.last,route: Route.find_by(origin: origin, destination: destination),supplier_name: "ghasedak")
x.search_supplier
x.register_request # for the ones that has two level RQ/RS
```
## Run
`docker-compose up`  
For some reasons, `assets:precompile` does not add font folder to the public/assets. cp them manually from `/app/assets/fonts` to `/public/assets/fonts`

## Copyright
Do whatever you want.
