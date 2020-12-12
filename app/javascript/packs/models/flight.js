export default class Flight {
  constructor(id, flightNumber, departure, arrival, price, supplier, deepLink) {
    this.id = id
    this.flightNumber = flightNumber
    this.departure = departure
    this.arrival = arrival
    this.price = price
    this.supplier = supplier
    this.deepLink = deepLink
  }
}
