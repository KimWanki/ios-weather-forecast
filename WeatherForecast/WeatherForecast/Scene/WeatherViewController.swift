//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation

extension Notification.Name {
    static let refreshLocation = Notification.Name("refreshLocation")
}

class WeatherViewController: UIViewController {
    private var currentCoordinate: Coordinate?
    private var currentWeather: TodayWeatherInfo?
    private var weatherForecast: WeeklyWeatherForecast?
    
    private let locationManager = WeatherLocationManager()
    private let networkManager = NetworkManager()
    
    private let weatherView = WeatherView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestLocation()
        
        applyViewSetting()
        configureWeatherTableView()
        configureRefreshControl()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveRefreshFinish),
                                               name: .refreshLocation,
                                               object: nil)
    }
}

// MARK: View Configuration
extension WeatherViewController: ViewConfiguration {
    func buildHierarchy() {
        view.addSubViews(weatherView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            weatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherView.topAnchor.constraint(equalTo: view.topAnchor),
            weatherView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func configureViews() {
        view.backgroundColor = .white
    }
}

extension WeatherViewController {
    func configureWeatherTableView() {
        weatherView.forecastTableView.dataSource = self
        weatherView.forecastTableView.delegate = self
        weatherView.forecastTableView.register(
            WeatherTableHeaderView.self,
            forHeaderFooterViewReuseIdentifier: WeatherTableHeaderView.reuseIdentifier
        )
        weatherView.forecastTableView.register(
            WeatherTableViewCell.self,
            forCellReuseIdentifier: WeatherTableViewCell.reuseIdentifier
        )
    }
}

// MARK: - LocationSettingDelegate
extension WeatherViewController: LocationSettingDelegate {
    func showAlert(hasAddress: Bool) {
        if hasAddress {
            showLocationChangeAlert(title: "위치 변경",
                                    message: "변경할 좌표를 선택해주세요.")
        } else {
            showLocationChangeAlert(title: "위치 변경",
                                    message: "날씨를 받아올 위치의 위도와 경도를 입력해주세요.",
                                    hasAddress: false)
        }
    }
}

// MARK: - TableViewDataSource, TableViewDelegate
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: WeatherTableHeaderView.reuseIdentifier
        ) as? WeatherTableHeaderView
        else { fatalError() }
        
        header.locationSettingDelegate = self
        currentWeather.flatMap { header.configure(with: $0) }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WeatherTableViewCell.reuseIdentifier)
                as? WeatherTableViewCell
        else { fatalError() }
        
        weatherForecast?.list.flatMap {
            cell.configure(with: $0[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForecast?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        case .restricted, .denied:
            showCLAuthorizationAlert(title: "위치 서비스 제공이 불가능합니다.",
                                     message: "어플리케이션 설정에서 위치 권한을 허용해주세요.")
        default:
            showCLAuthorizationAlert(title: "위치 서비스 제공이 불가능합니다.",
                                     message: "개발자에게 신고해주세요.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
        else { return }
        currentCoordinate = Coordinate(longitude: ceil(location.coordinate.longitude * 1_000) / 1_000,
                                       latitude: ceil(location.coordinate.latitude * 1_000) / 1_000)
        requestWeatherAPI(coordinate: currentCoordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}

private extension WeatherViewController {
    func requestWeatherAPI(coordinate: Coordinate?) {
        let group = DispatchGroup()
        coordinate.flatMap { coord in
            group.enter()
            networkManager.request(
                with: TodayWeatherInfo.self,
                parameters: coord.parameters
            ) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.currentWeather = model
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
            group.enter()
            networkManager.request(
                with: WeeklyWeatherForecast.self,
                parameters: coord.parameters
            ) { [weak self] result in
                switch result {
                case .success(let model):
                    self?.weatherForecast = model
                case .failure(let error):
                    print(error)
                }
                group.leave()
            }
        }
        group.wait()
        DispatchQueue.main.async {
            self.weatherView.forecastTableView.reloadData()
        }
        NotificationCenter.default.post(name: NSNotification.Name.refreshLocation, object: nil)
    }
}

// MARK: - Refresh Control
extension WeatherViewController {
    func configureRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "날씨 업데이트 중")
        weatherView.forecastTableView.refreshControl = refreshControl
        weatherView.forecastTableView.refreshControl?.addTarget(
            self,
            action: #selector(handleRefreshControl),
            for: .valueChanged
        )
    }
    
    @objc func handleRefreshControl() {
        self.locationManager.requestLocation()
    }
    
    @objc func didReceiveRefreshFinish() {
        DispatchQueue.main.async {
            self.weatherView.forecastTableView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - AlertController
extension WeatherViewController {
    func showLocationChangeAlert(title: String, message: String, hasAddress: Bool = true) {
        guard let coord = currentCoordinate else { return }
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if hasAddress {
                alert.addTextField { (latitudeTextField) in
                    latitudeTextField.placeholder = "위도"
                    latitudeTextField.text = String(describing: coord.latitude)
                }
                alert.addTextField { (longitudeTextField) in
                    longitudeTextField.placeholder = "경도"
                    longitudeTextField.text = String(describing: coord.longitude)
                }
                
                let requestSettingLocation = UIAlertAction(title: "변경", style: .default) { _ in
                    let latitude = alert.textFields?.first?.text
                        .flatMap { Double($0) }.flatMap { round($0 * 1_000) / 1_000 }
                    let longitude = alert.textFields?.last?.text
                        .flatMap { Double($0) }.flatMap { round($0 * 1_000) / 1_000 }
                    
                    if let lat = latitude, let lon = longitude {
                        self.currentCoordinate = Coordinate(longitude: lon, latitude: lat)
                        self.requestWeatherAPI(coordinate: Coordinate(longitude: lon, latitude: lat))
                    }
                }
                let requestCurrentLocation = UIAlertAction(title: "현재 위치로 재설정", style: .default) { _ in
                    self.locationManager.requestLocation()
                }
                
                alert.addAction(requestSettingLocation)
                alert.addAction(requestCurrentLocation)
            } else {
                alert.addTextField { (latitudeTextField) in
                    latitudeTextField.placeholder = "위도"
                }
                alert.addTextField { (longitudeTextField) in
                    longitudeTextField.placeholder = "경도"
                }
                
                let requestSettingLocation = UIAlertAction(title: "변경", style: .default) { _ in
                    let latitude = alert.textFields?.first?.text
                        .flatMap { Double($0) }
                        .flatMap { round($0 * 1_000) / 1_000 }
                    let longitude = alert.textFields?.last?.text
                        .flatMap { Double($0) }
                        .flatMap { round($0 * 1_000) / 1_000 }
                    if let lat = latitude, let lon = longitude {
                        self.currentCoordinate = Coordinate(longitude: lon, latitude: lat)
                        self.requestWeatherAPI(coordinate: Coordinate(longitude: lon, latitude: lat))
                    }
                }
                alert.addAction(requestSettingLocation)
            }
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showCLAuthorizationAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
            
            let okAction = UIAlertAction(
                title: "OK",
                style: .default,
                handler: nil)
            alert.addAction(okAction)
        }
    }
}
