//
//  URLGenerator.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/10/05.
//

import Foundation

struct URLGenerator {
    enum FileType: String, CustomStringConvertible {
        case png = ".png"
        
        var description: String {
            rawValue
        }
    }
    
    private static let baseURL = "https://api.openweathermap.org/data/2.5/"
    private static let iconURL = "https://openweathermap.org/img/w/"
    
    func generate(
        endpoint: String,
        parameters: [String: Any]
    ) -> URL? {
        var components = URLComponents(string: Self.baseURL + endpoint)
        var queryItems = [URLQueryItem]()
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: String(describing: value)))
        }
        queryItems.append(
            URLQueryItem(
                name: WeatherAPI.APIKey.name,
                value: WeatherAPI.APIKey.value
            )
        )
        components?.queryItems = queryItems
        return components?.url
    }
    
    func generateImageURL(with endpoint: String) -> String {
        return URLGenerator.iconURL + endpoint + String(describing: FileType.png)
    }
}
