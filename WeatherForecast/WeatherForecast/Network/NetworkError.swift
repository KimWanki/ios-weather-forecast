//
//  NetworkError.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/10/05.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case dataIsNil
    case unknown(description: String)
    case clientSide(description: String)
    case serverSide(description: String)
}
