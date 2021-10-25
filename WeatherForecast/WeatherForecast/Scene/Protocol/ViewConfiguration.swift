//
//  ViewConfiguration.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/20.
//

import Foundation

protocol ViewConfiguration {
    func buildHierarchy()
    func setupConstraints()
    func configureViews()
}

extension ViewConfiguration {
    func configureViews() {}
    
    func applyViewSetting() {
        buildHierarchy()
        setupConstraints()
        configureViews()
    }
}
