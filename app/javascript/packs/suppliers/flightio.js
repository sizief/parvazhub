import Flight from '../models/flight'
import Base from './base'

const supplier_name = 'flightio'
const axios = require('axios');

export default class Flightio extends Base{

  delay (ms) {
    return new Promise(res => setTimeout(res, ms));
  }

  params(){
    return ({
      "ADT": 1,
      "CHD": 0,
      "INF": 0,
      "CabinType": '1',
      "flightType": '2',
      "tripMode": '1',
      "DestinationInformationList": [
        {
          "DepartureDate": `${this.date}T00:00:00`,
          "DestinationLocationAirPortCode": this.destination.toUpperCase(),
          "DestinationLocationAllAirport": true,
          "DestinationLocationCityCode": this.destination.toUpperCase(),
          "Index": 1,
          "OriginLocationAirPortCode": this.origin.toUpperCase(),
          "OriginLocationAllAirport": true,
          "OriginLocationCityCode": this.origin.toUpperCase()
        }
      ]
    })
  }

  headers(){
    return({
      'Access-Control-Allow-Origin': '*',
      "FUser": 'FlightioAppAndroid',
      "FPass": 'Pw4FlightioAppAndroid',
      "FApiVersion": '1.1',
      "Content-Type": 'application/json'
    })
  }

  async search(){
    console.log(this.params())
    console.log(this.headers())
    console.log(this.urlRegister)
   // const response = await axios.post(
   //   this.urlRegister,
   //   JSON.stringify(this.params()),
   //   { headers: this.headers(), crossDomain: true}
   // )

  // const response = await fetch(this.urlRegister, {
  //  headers: {
  //    'Content-Type': 'application/json',
  //    'FUser': 'FlightioAppAndroid',
  //    "FPass": 'Pw4FlightioAppAndroid',
  //    "FApiVersion": '1.1',
  //    "FSession": "2f202eee-8595-4ba7-b427-7f3a69ecef02"
  //  },
  //  method: 'POST', // *GET, POST, PUT, DELETE, etc.
  //  mode: 'no-cors', // no-cors, *cors, same-origin
    //cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
    //credentials: 'same-origin', // include, *same-origin, omit
  //  redirect: 'follow', // manual, *follow, error
  //  referrerPolicy: 'no-referrer', // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
  //  body: JSON.stringify(this.params()) // body data type must match "Content-Type" header
 // })
    
//  var xhr = new XMLHttpRequest();
//xhr.open("POST", this.urlRegister, false);

//Send the proper header information along with the request
//xhr.setRequestHeader("Content-Type", "application/json");
//xhr.setRequestHeader("FUser", "FlightioAppAndroid");
//xhr.setRequestHeader("FPass", "Pw4FlightioAppAndroid");
//xhr.setRequestHeader("FApiVersion", "1.1");
//xhr.onreadystatechange = function() { // Call a function when the state changes.
//    if (this.readyState === XMLHttpRequest.DONE && this.status === 200) {
//        // Request finished. Do processing here.
 //   }
 // }
//xhr.send(JSON.stringify(this.params()));
//    console.log(reponse)
    //
    const response = await axios({
          method: 'post',
          url: this.urlRegister,
          data: JSON.stringify(
            this.params()
          ),
          headers: this.headers()
        })
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
