//
//  WeeklyWeatherInfo.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/09/28.
//

import Foundation

struct WeatherForecast: Codable {
    let forecastedTime: Int?
    let main: WeatherNumericalValue?
    let weather: [WeatherExpression]?
    let clouds: Clouds?
    let wind: Wind?
    let visibility: Int?
    let pop: Double?
    let rain: Rain?
    let snow: Snow?
    let sys: WeeklySys?
    let formattedForecastedTime: String?
    
    enum CodingKeys: String, CodingKey {
        case main, weather, clouds, wind, visibility, pop, rain, snow, sys
        case forecastedTime = "dt"
        case formattedForecastedTime = "dt_txt"
    }
}

struct WeeklyWeatherForecast: Codable {
    let message: Int?
    let timestampCount: Int?
    let list: [WeatherForecast]?
    let city: City?
    
    enum CodingKeys: String, CodingKey {
        case message, list, city
        case timestampCount = "cnt"
    }
}

extension WeeklyWeatherForecast: Requestable {
    static let endpoint = "forecast"
}

extension WeatherForecast {
    var localeForecast: String? {
        forecastedTime.flatMap {
            let date = Date(timeIntervalSince1970: TimeInterval($0))
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "MM/dd(E) HH시"
            
            return dateFormatter.string(from: date)
        }
    }
}
