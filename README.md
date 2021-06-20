# PARVAZHUB
[PARVAZHUB](https://parvazhub.com) is a domestic Iranian flight metasearch website.  
  
## Helpers
To search on console:  
```
origin='mhd'; destination='thr';x=Suppliers::Ghasedak.new(origin: origin,destination: destination,date: (Date.today+1).to_s,search_history: SearchHistory.last,route: Route.find_by(origin: origin, destination: destination),supplier_name: "ghasedak")
x.search_supplier
x.register_request # for the ones that has two level RQ/RS
```

For some reasons, `assets:precompile` does not add font folder to the public/assets. cp them manually from `/app/assets/fonts` to `/public/assets/fonts`

## TODO
- remove user nonsense
- add gmail login
- add photos of the airplane by passengers | 7 | 5 = 1.4
- community for reviewers | 4 | 6 = 0.7

## Copyright
Do whatever you want.
