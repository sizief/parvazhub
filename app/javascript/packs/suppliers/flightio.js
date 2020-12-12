import Flight from '../models/flight'

export default class Flightio {
  constructor(origin, destination, date) {
    this.origin = origin
    this.destination = destination
    this.date = date
  }

  delay (ms) {
    return new Promise(res => setTimeout(res, ms));
  }

  async search(){
    const resultsModel = [
      new Flight(null, null, null, null, 1000, 'flightio', null)
    ]

    console.log("Waited 5s");
    await this.delay(5000);
    return resultsModel 
  }
}
