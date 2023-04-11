//
//  ApiService.swift
//  Currency Converter
//
//  Created by Md. Yamin on 9/15/22.
//

import Foundation
import Combine

class ApiService {
    
    static let shared = ApiService()
    
    func latestCurrencyUpdate(viewModel: BaseViewModel) -> AnyPublisher<CurrencyUpdateResponse, Error>? {
        var queryItems = [URLQueryItem]()
        
        queryItems.append(URLQueryItem(name: "app_id", value: ApiConstants.appId))
        
        guard var urlComponents = URLComponents(string: ApiConstants.latestUpdate) else {
            print("Problem in UrlComponent creation...")
            return nil
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        //Request type
        var request = getCommonUrlRequest(url: url)
        request.httpMethod = ApiConstants.get
        
        return getDataTask(request: request, viewModel: viewModel)
    }
    
    private func getCommonUrlRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        // Set common headers like authentication tokens
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func getDataTask<T: Codable>(request: URLRequest, viewModel: BaseViewModel) -> AnyPublisher<T, Error>? {
        return viewModel.session.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                viewModel.showLoader.send(true)
            }, receiveOutput: { _ in
                viewModel.showLoader.send(false)
            }, receiveCompletion: { _ in
                viewModel.showLoader.send(false)
            }, receiveCancel: {
                viewModel.showLoader.send(false)
            })
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw AppError.InvalidServerResponse
                }
            
                return data
        }
        .retry(0)
        .decode(type: T.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
