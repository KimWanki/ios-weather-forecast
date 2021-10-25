//
//  WeatherTableViewHeader.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/17.
//

import UIKit

protocol LocationSettingDelegate: AnyObject {
    func showAlert(hasAddress: Bool)
}

class WeatherTableHeaderView: UITableViewHeaderFooterView {
    private enum HeaderInit {
        static let defaultValue = "-"
    }
    private enum Constraint {
        static let inset: CGFloat = 10
    }
    
    static let reuseIdentifier = "\(WeatherTableHeaderView.self)"
    
    weak open var locationSettingDelegate: LocationSettingDelegate?
    
    private let iconImageView: UIImageView = { return UIImageView(frame: .zero) }()

    private let addressLabel: UILabel = { return UILabel(frame: .zero) }()
    private let minMaxTemperatureLabel: UILabel = { return UILabel(frame: .zero) }()
    private let currentTemperatureLabel: UILabel = { return UILabel(frame: .zero) }()
    
    private let locationSettingButton: UIButton = { return UIButton() }()
    
    private let currentWeatherStackView: UIStackView = { return UIStackView() }()
    private let containerStackView: UIStackView = { return UIStackView() }()
    
    // MARK: Initialize
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        if #available(iOS 14.0, *) {
            self.backgroundConfiguration = .clear()
        } else {
            self.backgroundColor = .clear
        }
        applyViewSetting()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyViewSetting()
    }
}

// MARK: - View Configuration
extension WeatherTableHeaderView: ViewConfiguration {
    func buildHierarchy() {
        contentView.addSubViews(containerStackView, locationSettingButton)
        containerStackView.addArrangedSubviews(iconImageView,
                                               currentWeatherStackView)
        currentWeatherStackView.addArrangedSubviews(addressLabel,
                                                    minMaxTemperatureLabel,
                                                    currentTemperatureLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                    constant: Constraint.inset),
            containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                       constant: -Constraint.inset),
            containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: locationSettingButton.trailingAnchor),
            
            locationSettingButton.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                       constant: Constraint.inset),
            locationSettingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                            constant: -Constraint.inset),
            
            iconImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.22),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor)
        ])
    }
    
    func configureViews() {
        containerStackView.axis = .horizontal
        containerStackView.alignment = .fill
        containerStackView.distribution = .fillProportionally
        
        currentWeatherStackView.axis = .vertical
        currentWeatherStackView.alignment = .fill
        currentWeatherStackView.distribution = .equalSpacing
        
        addressLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        addressLabel.textColor = .black
        
        minMaxTemperatureLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        minMaxTemperatureLabel.textColor = .black
        
        currentTemperatureLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        currentTemperatureLabel.textColor = .black
        
        locationSettingButton.setTitle("위치설정", for: .normal)
        locationSettingButton.setTitleColor(.black, for: .normal)
        locationSettingButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        locationSettingButton.backgroundColor = .clear
        locationSettingButton.addTarget(self, action: #selector(didTapLocationSettingButton), for: .touchUpInside)
    }
    
    @objc func didTapLocationSettingButton() {
        addressLabel.text
            .flatMap { if $0 == HeaderInit.defaultValue {
                locationSettingDelegate?.showAlert(hasAddress: false)
            } else {
                locationSettingDelegate?.showAlert(hasAddress: true)
            }
        }
    }
}

// MARK: - Configure Cell
extension WeatherTableHeaderView {
    override func prepareForReuse() {
        addressLabel.text = "-"
        minMaxTemperatureLabel.text = "-"
        currentTemperatureLabel.text = "-"
        iconImageView.image = nil
    }
    
    func configure(with weather: TodayWeatherInfo) {
        weather.coordinate
            .flatMap { $0.convertToAddress { placemark in
                    if let name = placemark.name,
                       let local = placemark.locality {
                        self.addressLabel.text = "\(local) \(name)"
                    }
                }
            }
        
        weather.main
            .flatMap { $0.convertToCelsius(with: $0.minimumTemperature) }
            .flatMap { self.minMaxTemperatureLabel.text = "최소 \($0)°" }
        
        weather.main
            .flatMap { $0.convertToCelsius(with: $0.maximumTemperature) }
            .flatMap { self.minMaxTemperatureLabel.text! += " 최대 \($0)°" }
        
        weather.main
            .flatMap { $0.convertToCelsius(with: $0.temperature) }
            .flatMap { self.currentTemperatureLabel.text = "\($0)°" }
        
        weather.weather?.first?.icon
            .flatMap { configureImage(with: $0) }
    }
    
    func configureImage(with iconType: String) {
        let url = URLGenerator().generateImageURL(with: iconType)
        imageLoader.loadImage(from: url) { image in
            imageCache.add(image, forKey: url)
            DispatchQueue.main.async {
                self.iconImageView.image = image
            }
        }
    }
}
