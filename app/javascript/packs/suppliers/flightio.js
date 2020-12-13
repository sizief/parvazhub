import Flight from '../models/flight'
import Base from './base'

const supplier_name = 'flightio'

export default class Flightio extends Base{

  delay (ms) {
    return new Promise(res => setTimeout(res, ms));
  }

  async search(){
    const results = [
      new Flight(
        {
          id: null,
          flightNumber: null,
          departure: null,
          arrival: null,
          price: 100,
          supplier: supplier_name,
          deepLink: null,
          slug: 1
        }
      )
    ]

    console.log("Waited 5s");
    await this.delay(5000);
    return results
  }
}
