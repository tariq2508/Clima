//
//  WeatherManager.swift
//  Clima
//
//  Created by Tariq Islam on 1/15/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=0e798cfefb569dba6a9eb632fe464768&units=imperial"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        performRequest(with: urlString)
    }
    
//    func fetchWeather(latitude: CLLocationDegrees, lontitude: CLLocationDegrees) {
//        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(lontitude)"
//        print(urlString)
//    }
    

    
    func performRequest (with urlString: String) {
        //1. create a URL
        
        if let url = URL(string: urlString) {
            //2. create a URLSession
            
            let session = URLSession(configuration: .default)
            
            //3. Give the session a task
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                
                if let safeData = data {
                    //let dataString = String(data: safeData, encoding: .utf8)
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
            }
            
            //let task = session.dataTask(with: url, completionHandler: handle(data:response:error:))
            
            //4. Start the task
            
            task.resume()
            
        }
  
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let description = decodedData.weather[0].description
            let temp = decodedData.main.temp
            let name = decodedData.name
//            print(decodedData.main.temp)
//            print(decodedData.weather[0].description)
//            print(decodedData.weather[0].id)
            
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp, description: description)
            
            print(weather.temperatureString)
            print(weather.description)
            print(weather.conditionName)
            return weather
            
        } catch {
            print(error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    

    
    
}
