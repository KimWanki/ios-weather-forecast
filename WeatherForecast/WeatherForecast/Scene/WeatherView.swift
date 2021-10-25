//
//  WeatherView.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/15.
//

import UIKit

class WeatherView: UIView {
    private enum PlaceImage {
        static let backgroundImage = "backgroundImage"
    }
    
    lazy var forecastTableView = UITableView(frame: .zero,
                                             style: .grouped)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        applyViewSetting()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyViewSetting()
    }
}

extension WeatherView: ViewConfiguration {
    func buildHierarchy() {
        self.addSubViews(forecastTableView)
    }
    
    func configureViews() {
        forecastTableView.backgroundColor = .clear
        forecastTableView.backgroundView = UIImageView(image: UIImage(named: PlaceImage.backgroundImage))
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            forecastTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            forecastTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            forecastTableView.topAnchor.constraint(equalTo: self.topAnchor),
            forecastTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
