//
//  NetworkManager.swift
//  WeatherForecast
//
//  Created by 샬롯, 수박, 루얀 on 2021/09/30.
//

import Foundation

protocol URLSessionable {
    func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
    
    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask
    
    func invalidateAndCancel()
}

extension URLSession: URLSessionable { }

struct NetworkManager {
    private let urlGenerator = URLGenerator()
    private let session: URLSessionable
    
    init(session: URLSessionable = URLSession.shared) {
        self.session = session
    }
    
    func request<Model: Requestable>(
        with model: Model.Type,
        parameters: [String: Any],
        httpMethod: HTTPMethod = HTTPMethod.get,
        completion: @escaping (Result<Model, Error>) -> Void
    ) {
        guard let url = urlGenerator.generate(
            endpoint: Model.endpoint,
            parameters: parameters
        ) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = String.init(describing: httpMethod)
        
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                let unknownError = NetworkError.unknown(
                    description: error.localizedDescription
                )
                completion(.failure(unknownError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            switch response.statusCode {
            case 200..<300:
                handleSuccessStatusCode(data: data, completion: completion)
            default:
                handleFailureStatusCode(response: response, completion: completion)
            }
        }.resume()
    }
    
    private func handleSuccessStatusCode<Model: Requestable>(
        data: Data?,
        completion: @escaping (Result<Model, Error>) -> Void
    ) {
        guard let data = data else {
            completion(.failure(NetworkError.dataIsNil))
            return
        }
        
        do {
            let model: Model = try Parser.decode(data)
            completion(.success(model))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func handleFailureStatusCode<Model>(
        response: HTTPURLResponse,
        completion: @escaping (Result<Model, Error>) -> Void
    ) {
        switch response.statusCode {
        case 400..<500:
            completion(.failure(NetworkError.clientSide(description: response.debugDescription)))
        case 500..<600:
            completion(.failure(NetworkError.serverSide(description: response.debugDescription)))
        default:
            completion(.failure(NetworkError.unknown(description: response.debugDescription)))
        }
    }
}
