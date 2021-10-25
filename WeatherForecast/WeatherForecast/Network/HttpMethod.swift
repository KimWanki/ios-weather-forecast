//
//  httpMethod.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/13.
//

import Foundation

enum HTTPMethod: String {
    case get
    case post
    case put
    case patch
    case delete
    
    var description: String {
        rawValue
    }
}
