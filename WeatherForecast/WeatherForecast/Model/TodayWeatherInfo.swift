//
//  TodayWeatherInfo.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/09/28.
//

import Foundation

struct TodayWeatherInfo: Codable {
    let coordinate: Coordinate?
    let weather: [WeatherExpression]?
    let base: String?
    let main: WeatherNumericalValue?
    let visibility: Double?
    let wind: Wind?
    let clouds: Clouds?
    let calculatedTime: TimeInterval?
    let sys: TodaySys?
    let timezone: Int?
    let identifier: Int?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case weather, base, main, visibility, wind, clouds, sys, timezone, name
        case coordinate = "coord"
        case calculatedTime = "dt"
        case identifier = "id"
    }
}

extension TodayWeatherInfo: Requestable {
    static let endpoint = "weather"
}
