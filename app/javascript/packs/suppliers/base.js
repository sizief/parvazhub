export default class Base {
  constructor({origin, destination, date, urlSearch, urlRegister, urlDeeplink}={}) {
    this.origin = origin
    this.destination = destination
    this.date = date
    this.urlSearch = urlSearch
    this.urlRegister = urlRegister
    this.urlDeeplink = urlDeeplink
  }
}
