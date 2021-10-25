//
//  Sys.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/10/05.
//

import Foundation

struct WeeklySys: Codable {
    let pod: String?
}

struct TodaySys: Codable {
    let type: Int?
    let identifier: Int?
    let message: Double?
    let country: String?
    let sunrise: TimeInterval?
    let sunset: TimeInterval?
    
    enum CodingKeys: String, CodingKey {
        case type, message, country, sunrise, sunset
        case identifier = "id"
    }
}
