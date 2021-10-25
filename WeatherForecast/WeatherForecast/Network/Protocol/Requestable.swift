//
//  baseModel.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/11.
//

import Foundation

protocol Requestable: Decodable {
    static var endpoint: String { get }
}
