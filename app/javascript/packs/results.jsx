import React from 'react'
import ReactDOM from 'react-dom'
import PropTypes from 'prop-types'
import SearchResult from './search-results'
import Flightio from './suppliers/flightio'

document.addEventListener('DOMContentLoaded', () => {
  const data = window.params
  const suppliersClasses = {
    flightio: Flightio
  }
  const suppliers = data.suppliers.map(supplier=> suppliersClasses[supplier])

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
