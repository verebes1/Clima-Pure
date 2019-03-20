//
//  ViewController.swift
//  WeatherApp
//
//  Created by Verebes on 23/08/2017.
//  Copyright (c) 2017 AD Progress. All rights reserved.
//

import UIKit
import CoreLocation


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "8a5f77889dbdb03403fcdbfe3f053215"
    
    
    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    var weatherDataModel: WeatherDataModel!
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // specify the accuracy for the coordinates
        locationManager.requestWhenInUseAuthorization() //you need to add to plist Privacy and request string
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: String){
        //URL Session configuration
        let defaultSession = URLSession(configuration: .default)
        var dataTask: URLSessionDataTask?
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: WEATHER_URL) {
            urlComponents.query = parameters
            
            guard let url = urlComponents.url else { return }
            print("URL PASSED \(url)")
            dataTask = defaultSession.dataTask(with: url) { data, response, error in
                defer { dataTask = nil }
                
                if let responseData = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    print("DATA RECEIVED")
//                    do {
//                        let json = try JSONSerialization.jsonObject(with: responseData, options: [.mutableContainers]) as? [String: Any]
//                        let json = responseData.prettyPrintedJSONString!
//                        print(json)
//                    } catch {
//                        print(error.localizedDescription)
//                    }
                    guard let jsonString = String(data: responseData, encoding: String.Encoding.utf8) else { return }
                    print(jsonString)
                    
                    self.updateWeatherData(data: responseData)
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            dataTask?.resume()
        }
    }
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    //Write the updateWeatherData method here:
    func updateWeatherData(data: Data) {
        do {
            //            weatherDataModel = try JSONDecoder().decode(WeatherDataModel.self, from: data)
            let decoder = JSONDecoder()
            weatherDataModel = try decoder.decode(WeatherDataModel.self, from: data)
            DispatchQueue.main.async {
                self.updateUIWithWeatherData()
            }
        } catch let error {
            print("We are doomed")
            print(error.localizedDescription)
            DispatchQueue.main.async {
                self.cityLabel.text = "Weather unavailable :("
            }
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    //This method turns a condition code into the name of the weather condition image
    func updateWeatherIcon(condition: Int) -> String {
        
        switch (condition) {
        case 0...300 :
            return "tstorm1"
        case 301...500 :
            return "light_rain"
        case 501...600 :
            return "shower3"
        case 601...700 :
            return "snow4"
        case 701...771 :
            return "fog"
        case 772...799 :
            return "tstorm3"
        case 800 :
            return "sunny"
        case 801...804 :
            return "cloudy2"
        case 900...903, 905...1000  :
            return "tstorm3"
        case 903 :
            return "snow5"
        case 904 :
            return "sunny"
        default :
            return "dunno"
        }
        
    }
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData(){
        temperatureLabel.text = "\(Int(weatherDataModel.main.temp - 273))"
        cityLabel.text = weatherDataModel.name
        let weatherIconName = updateWeatherIcon(condition: weatherDataModel?.weather[0].id ?? 9990)
        weatherIcon.image = UIImage(named: weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 { //if it is below zero it is invalid this is why we check this
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("Latitude: \(location.coordinate.latitude) Logitude: \(location.coordinate.longitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params: String = "lat=\(latitude)&lon=\(longitude)&appid=\(APP_ID)"
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location unavailable!"
        
    }
    
    
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        print(city)
        
        let params: String = "q=\(city)&appid=\(APP_ID)"
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self //we are setting the ChangeCityViewController's delegate to be this View Controller which is WeatheViewController
        }
    }
}



