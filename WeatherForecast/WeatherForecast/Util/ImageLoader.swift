//
//  ImageLoader.swift
//  WeatherForecast
//
//  Created by WANKI KIM on 2021/10/18.
//

import UIKit

let imageLoader = ImageLoader(session: URLSession.shared)

class ImageLoader {
    private let session: URLSessionable
    
    init(session: URLSessionable) {
        self.session = session
    }
    
    func loadImage(from url: String, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil,
                  let data = data
            else { return }
            
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode) else {
                return
            }
            
            guard let thumnailImage = UIImage(data: data) else { return }
                completionHandler(thumnailImage)
        }.resume()
    }
    
    func cancel() {
        session.invalidateAndCancel()
    }
}
