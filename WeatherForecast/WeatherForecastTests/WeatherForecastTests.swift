//
//  WeatherForecastTests - WeatherForecastTests.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import XCTest
@testable import WeatherForecast

class WeatherForecastTests: XCTestCase {
    func test_TodayWeatherInfo모델_디코딩이성공하면_같은temperature값이나온다() {
        guard let path = Bundle.main.path(forResource: "sampleOfCurrent", ofType: "json"),
              let jsonData = try? String(contentsOfFile: path).data(using: .utf8) else {
                  return XCTFail()
              }

        do {
            let result = try JSONDecoder().decode(TodayWeatherInfo.self, from: jsonData)
            XCTAssertEqual(282.55, result.main!.temperature)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func test_WeeklyWeatherInfo모델_디코딩이성공하면_같은temperature값이나온다() {
        guard let path = Bundle.main.path(forResource: "sampleOfWeek", ofType: "json"),
              let jsonData = try? String(contentsOfFile: path).data(using: .utf8) else {
                  return XCTFail()
              }
        
        do {
            let result = try JSONDecoder().decode(WeeklyWeatherForecast.self, from: jsonData)
            XCTAssertEqual(293.55, result.list!.first!.main!.temperature)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

