//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Verebes on 23/08/2017.
//  Copyright (c) 2017 AD Progress. All rights reserved.
//

import UIKit

struct WeatherDataModel: Codable {
    let weather: [Weather]
    let main: Main
    let visibility: Int
    let name: String
    let cod: Int
}

struct Main: Codable {
    let temp: Double
    let pressure, humidity: Int
    let tempMin, tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}

