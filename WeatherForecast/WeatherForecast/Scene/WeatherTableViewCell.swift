//
//  WeatherTableViewCell.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/17.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    private enum Constraint {
        static let inset: CGFloat = 10
    }
    static let reuseIdentifier = "\(WeatherTableViewCell.self)"
    
    private let dateLabel: UILabel = {
        return UILabel()
    }()
    
    private let temperatureLabel: UILabel = {
        return UILabel()
    }()
    
    private let iconImageView: UIImageView = {
        return UIImageView()
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyViewSetting()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyViewSetting()
    }
}

extension WeatherTableViewCell: ViewConfiguration {
    func buildHierarchy() {
        contentView.addSubViews(iconImageView, dateLabel, temperatureLabel)
    }
    
    func configureViews() {
        self.backgroundColor = .clear
        
        dateLabel.textColor = .darkGray
        
        temperatureLabel.textColor = .darkGray
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constraint.inset),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constraint.inset),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constraint.inset),
            
            temperatureLabel.leadingAnchor.constraint(
                greaterThanOrEqualTo: dateLabel.trailingAnchor,
                constant: Constraint.inset),
            temperatureLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Constraint.inset),
            temperatureLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Constraint.inset),
            temperatureLabel.trailingAnchor.constraint(
                equalTo: iconImageView.leadingAnchor,
                constant: -Constraint.inset),
            
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constraint.inset),
            
            iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor)
        ])
    }
}

extension WeatherTableViewCell {
    override func prepareForReuse() {
        imageLoader.cancel()
        self.dateLabel.text = nil
        self.temperatureLabel.text = nil
        self.iconImageView.image = nil
    }
    
    func configure(with forecast: WeatherForecast?) {
        forecast?.localeForecast
            .flatMap { self.dateLabel.text = $0 }
        
        forecast
            .flatMap { $0.main?.convertToCelsius(with: $0.main?.temperature) }
            .flatMap { self.temperatureLabel.text = "\($0)°" }
        
        forecast?.weather?.first?.icon
            .flatMap { configureImage(with: $0) }
    }
    
    func configureImage(with urlString: String) {
        let url = URLGenerator().generateImageURL(with: urlString)
        imageLoader.loadImage(from: url) { image in
            imageCache.add(image, forKey: url)
            DispatchQueue.main.async {
                self.iconImageView.image = image
            }
        }
    }
}
