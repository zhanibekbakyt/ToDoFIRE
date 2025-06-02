//
//  Weather.swift
//  ToDoFIRE
//
//  Created by Zhanibek Bakyt on 02.06.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let current_weather: CurrentWeather
}

struct CurrentWeather: Codable {
    let temperature: Double
    let windspeed: Double
    let weathercode: Int
}
