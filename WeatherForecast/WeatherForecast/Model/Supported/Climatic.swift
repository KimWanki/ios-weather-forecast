//
//  ClimateModels.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/10/05.
//

import Foundation

struct Wind: Codable {
    let speed: Double?
    let gust: Double?
    let degree: Int?
    
    enum CodingKeys: String, CodingKey {
        case speed, gust
        case degree = "deg"
    }
}

struct Clouds: Codable {
    let cloudiness: Int?
    
    enum CodingKeys: String, CodingKey {
        case cloudiness = "all"
    }
}

struct Rain: Codable {
    let volumeForThreeHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case volumeForThreeHours = "3h"
    }
}

struct Snow: Codable {
    let volumeForThreeHours: Double?
    
    enum CodingKeys: String, CodingKey {
        case volumeForThreeHours = "3h"
    }
}
