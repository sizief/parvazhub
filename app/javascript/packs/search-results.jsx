import React, { useEffect, useState } from "react"
import PropTypes from 'prop-types'
import Flight from './models/flight'

const SearchResult = props => {
  const [results, setResults] = useState([])

  const merge = (results, supplierResult) => {
    return supplierResult
  }

  const searchParamsFor = supplier => ({
    origin: props.origin,
    destination: props.destination,
    date: props.date,
    urlRegister: supplier.urlRegister,
    urlSearch: supplier.urlSearch,
    urlDeeplink: supplier.urlDeeplink
  })

  useEffect(() => {
    props.suppliers.forEach( supplier => {
      console.log(`searching ${supplier.name}`)
      new supplier.class(searchParamsFor(supplier))
        .search()
        .then(
          (res) => setResults(merge(results, res))
        ).catch(e => console.log(e));
    })
  }, [0]); // run only once

  return(
    <>
      <div>searching for {props.origin} to {props.destination} for {props.date}</div>
      {results.map(res=>(
        <div key={res.slug}>
          { res.supplier }
          { res.price }
        </div>
      ))}
    </>
  )
}

SearchResult.propTypes = {
  origin: PropTypes.string,
  destonation: PropTypes.string,
  date: PropTypes.string,
  suppliers: PropTypes.array,
}

export default SearchResult
