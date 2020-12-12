import React, { useEffect, useState } from "react"
import PropTypes from 'prop-types'
import Flight from './models/flight'

SearchResult.propTypes = {
  origin: PropTypes.string,
  destonation: PropTypes.string,
  date: PropTypes.string,
  suppliers: PropTypes.array,
}

const SearchResult = props => {
  const resultsModel = [new Flight]
  const [results, setResults] = useState(resultsModel)

  const merge = (results, supplierResult) => {
    return supplierResult
  }

useEffect(() => {
  props.suppliers.forEach(supplier=>{
    console.log(`searching ${supplier}`)
    new supplier(
      props.origin,
      props.destination,
      props.date
    ).search().then(
      (res) => setResults(merge(results, res))
    ).catch(e => console.log(e));
  })
}, [0]); // run only once

console.log(results)
  return(
    <>
      <div>searching for {props.origin} to {props.destination} for {props.date}</div>
      {results.map(res=>(
        <div>
          { res.supplier }
          { res.price }
        </div>
      ))}
    </>
  )
}

export default SearchResult
