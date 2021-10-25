//
//  Coordinate.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/09/28.
//

import Foundation
import CoreLocation

struct Coordinate: Codable {
    let longitude: Double
    let latitude: Double
    
    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

extension Coordinate {
    var parameters: [String: Any] {
        return ["lat": latitude, "lon": longitude]
    }
}

struct City: Codable {
    let identifier: Int?
    let name: String?
    let coordinate: Coordinate?
    let country: String?
    let timezone: Int?
    let sunrise: Int?
    let sunset: Int?
    
    enum CodingKeys: String, CodingKey {
        case name, country, timezone, sunrise, sunset
        case identifier = "id"
        case coordinate = "coord"
    }
}

extension Coordinate {
    func convertToAddress(completion: @escaping (CLPlacemark) -> Void) {
        let location = CLLocation.init(latitude: self.latitude, longitude: self.longitude)
        CLGeocoder().reverseGeocodeLocation(
            location,
            preferredLocale: Locale(identifier: "ko_KR")
        ) { (placemarks, error) in
            guard error == nil,
                  let placemark = placemarks?.last
            else { return }
            
            completion(placemark)
        }
    }
}
