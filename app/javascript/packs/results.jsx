import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import SearchResult from './search-results'
import Flightio from './suppliers/flightio'

document.addEventListener('DOMContentLoaded', () => {
  const data = window.params
  const suppliersClass = {
    flightio: Flightio
  }
  const suppliers = data.suppliers.map(supplier=> {
    supplier['class'] = suppliersClass[supplier.name]
    return supplier
  })

  ReactDOM.render(
    <SearchResult
      origin={data.origin}
      destination={data.destination}
      date={data.date}
      suppliers={suppliers}
    />,
    document.body.appendChild(document.createElement('div')),
  )
})
