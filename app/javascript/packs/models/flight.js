export default class Flight {
  constructor({id, flightNumber, departure, arrival, price, supplier, deepLink, slug} = {}) {
    this.id = id
    this.flightNumber = flightNumber
    this.departure = departure
    this.arrival = arrival
    this.price = price
    this.supplier = supplier
    this.deepLink = deepLink
    this.slug = slug
  }
}
